# docker
## build internals
Docker stores all images infromations in `/var/lib/docker`, all patchs in this section are relative to this location.
`docker build` create layer for each line in Dockerfile. This metadata contains information about Dockerfile instruction, copied files, runned commands and timestamps (so image sha change after second run if same content was not cached before). Part of this json is also `rootfs.diff_ids` that containes pointers to `./image/overlay2/layerdb/sha256/<sha>/diff` with reference to `/var/lib/docker/overlay2/<sha>` 

```bash
$ docker ps -qa
43ff50b881ef
$ cat /var/lib/docker/image/containers/43ff50b881ef2f7335872ba9470d8227fcb539f43b7e47866a83687d81c58ae2/config.v2.json | jq .Image
"sha256:49f356fa4513676c5e22e3a8404aad6c7262cc7aaed15341458265320786c58c"
$ cat /var/lib/docker/image/overlay2/imagedb/content/sha256/49f356fa4513676c5e22e3a8404aad6c7262cc7aaed15341458265320786c58c | jq .rootfs
{
  "type": "layers",
  "diff_ids": [
    "sha256:8ea3b23f387bedc5e3cee574742d748941443c328a75f511eb37b0d8b6164130"
  ]
}
$ cat /var/lib/docker/image/overlay2/layerdb/sha256/8ea3b23f387bedc5e3cee574742d748941443c328a75f511eb37b0d8b6164130/cache-id
edd1846fffdc3b51d7ba58689c6f3983712a20a3b95ba9357f9e0a56e139da30
$ ls /var/lib/docker/overlay2/edd1846fffdc3b51d7ba58689c6f3983712a20a3b95ba9357f9e0a56e139da30
committed  diff  link lower
```

There we can find file lower that contains list that will be provided to overlay mount as lowerdir.

Those are paths in `/var/lib/docker/overlay2/l/<link>` that are symbolik links to sha dirs from `/var/lib/docker/overlay2`. Root file system is build using overlay mount and passed to `runc` as `rootfs`.

## image tags
Docker layers can be taged on build `docker build . -t name:1.4` or at any time `docker tag 6495c39230ed name:1.4`. Tag contains:

`repository_url/namespace/repository:tag`


## Dockerfile
* **COPY** - creates layer directly using content being copied
* **ADD** - similar to COPY but works with remote directories and [unpacks files in fly](https://github.com/gliderlabs/docker-alpine/blob/c7368b846ee805b286d9034a39e0bbf40bc079b3/versions/library-3.5/Dockerfile)
* **RUN** - RUN echo > file (require shell) ["/path/bin"] only binary but not able to use. It runs a temporary container base on the last layer and saves the writable upper layer as a new one after running.```bash
Step 3/4 : RUN ["/main"] 
 ---> Running in cdcd8a897d8b
Hello!
Removing intermediate container cdcd8a897d8b
 ---> f8acc3eadde1```
