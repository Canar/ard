#!/data/data/info.guardianproject.lildebi/app_bin/sh

# many phones don't even include 'test', so set the path to our
# busybox tools first, where we provide all the UNIX tools needed by
# this script
export PATH=$1:$PATH

echo "========================================"
echo "./remove-debian-setup.sh"

test -e $1/lildebi-common || exit
. $1/lildebi-common

$1/stop-debian.sh

set -x

# force umount if stop-debian.sh failed
test -d $mnt/usr && umount -f $mnt
losetup -d $loopdev

rm $image_path
rm $image_path.sha1

mount -o remount,rw rootfs /
if [ -d $mnt ]; then
    rmdir $mnt
fi

# if the /bin symlink exists, delete it
if [ -h /bin ]; then
    rm /bin
fi
mount -o remount,ro rootfs /

#------------------------------------------------------------------------------#
# shortcuts for setting up the chroot in the terminal

if [ -e /data/local/bin/debian ]; then
    rm /data/local/bin/debian
fi

if [ -d /data/local/bin ]; then
    rmdir /data/local/bin
fi
