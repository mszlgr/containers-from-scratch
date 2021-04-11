# docker
docker build .creates sha256 for each layer -> this sha is sha of json document stored in /var/lib/docker/image/overlay2/imagedb/content/sha256/8967eedba0...
json is: information about Dockerfile instruction, copied files, run cmd and timestamps (so image sha change after second run ??)there is also rootfs.diff_ids = sha256:id which points to image/overlay2/layerdb/sha256/in this dir there is a file diff that points to /var/lib/docker/overlay2/sha 

when we start image it 
create ./containers/sha_container to store hostname, hosts, resolve.conf, log file, and configcreate ./image/overlay2/layerdb/mounts/sha_container to store info about overlays - between other about `mount-id` - which is sha pointer to ./overlay2/sha_mount_layer. There we can find file lower that contains eg l/BVHWFFOROY3SYP7SPLAJJSUKK7:l/XKNF53FVNK2QRRXWHCJBNFEK4V:l/U5XC34V5N7P3DJA4JDTUXQU3AW - list that will be provided to overlay mount as lowerdir. Those are paths in /var/lib/docker/overlay2/l/ that are links to sha dirs from /var/lib/docker/overlay2.Then rootfs is mounted it is passed to runc.

## Dockerfile
**COPY** - creates layer directly using content being copied
**ADD** - similar to COPY but works with remote directories and [unpacks files in fly](https://github.com/gliderlabs/docker-alpine/blob/c7368b846ee805b286d9034a39e0bbf40bc079b3/versions/library-3.5/Dockerfile)

**RUN** - RUN echo > file (require shell) ["/path/bin"] only binary but not able to use. It runs a temporary container base on the last layer and saves the writable upper layer as a new one after running.```bash
Step 3/4 : RUN ["/main"] 
 ---> Running in cdcd8a897d8b
Hello!
Removing intermediate container cdcd8a897d8b
 ---> f8acc3eadde1```
