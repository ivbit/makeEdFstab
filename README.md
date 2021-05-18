# makeEdFstab

The script copies /etc/fstab file to current working directory

and creates ed script file in current working directory

to add noatime,softdep to ./fstab.

After testing results in ./fstab,

addToFstab.ed can be used to change /etc/fstab, as root:

#### ed /etc/fstab < addToFstab.ed

The script is intended to run on OpenBSD.

