#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <linux/stat.h>
#include <linux/fcntl.h>
#include <blkid/blkid.h>
#include <unistd.h>
#include <libudev.h>

//void x(int r
typedef enum {stringpair} expforms;
typedef enum {nonzero} checkforms;

/* struct explanations{
//	valueclass value;
	char* message;
	void* data;
}

//const char* explanation={{nonzero
void check(int result,char* message,void* arg){
	if (result!=0) {
		printf(message, arg);
		exit(result);
	}
} */

const char* emsgs[]= 
{	"No problem! ^__~"
,	"%s requires at least 1 argument. User entered %i."
,	"Failed to open %s."
,	"Failed to stat %s."
,	"Out of memory!"
,	"Failed to set device on blkid probe."
,	"Failed to identify any partition table on %s"
,	"Failed to probe: %s"
};
int error_value;
#define handle(num,check,...) handlem(check,num,emsgs[num],##__VA_ARGS__);
#define abort(num,msg,...) {\
	printf(msg,##__VA_ARGS__); \
	return num; \
}

#define handlem(check,num,msg,...) if((check)) { abort(num,msg,##__VA_ARGS__) }
int errn;
char errmsg[256];
#define handlemz(num,func,...)\
	errmsg[0]=0; \
	strcat(errmsg,"ERROR: %s\n\t"); \
	strcat(errmsg,emsgs[num]); \
	handlem((errn=(func))<0,num,errmsg,strerror(errn),##__VA_ARGS__)

typedef enum e_error_mode { ERARG, EROPEN, ERSTAT } errormode;

//need better system for assertion
int main(int argc, char *argv[]) {
	struct stat st;
	int fd;
	int oflag=O_CLOEXEC|O_RDONLY|O_NONBLOCK|O_NOCTTY;
	const char *pttype = NULL;
	int r;
	int n;
	char* fn=argv[1];
	error_value=0;
	blkid_probe b;
	blkid_partlist pl;


	handle(		1,	argc<2,fn,argc);
	printf("sup.\n");
        handlemz(	2,	fd=open(argv[1],oflag),fn);
	handle(		3,	fstat(fd,&st)<0,fn);
        handle(		4,	!(b=blkid_new_probe()));
        handle(		5,	blkid_probe_set_device(b, fd, 0, 0));
        blkid_probe_enable_partitions(b, 1);
        blkid_probe_set_partitions_flags(b, BLKID_PARTS_ENTRY_DETAILS);

        r = blkid_do_safeprobe(b);
        handle(6,(r == -2 || r == 1),fn);
	handle(7,(r!=0),fn);

        blkid_probe_lookup_value(b, "PTTYPE", &pttype, NULL);
	printf("Partition type: %s", pttype);

        struct udev_enumerate *e = NULL;
        struct udev_device *d = NULL;
        struct udev *udev = NULL;
        struct udev_list_entry *first, *item;
 
        udev = udev_new();
        d = udev_device_new_from_devnum(udev, 'b', st.st_rdev);
	e = udev_enumerate_new(udev);
	r = udev_enumerate_add_match_parent(e, d);
	r = udev_enumerate_scan_devices(e);

	/* Count the partitions enumerated by the kernel */
	n = 0;
	first = udev_enumerate_get_list_entry(e);
	udev_list_entry_foreach(item, first)
                        n++;

	printf("udev found %i partitions.\n",n);
/*        is_gpt = streq_ptr(pttype, "gpt");
        is_mbr = streq_ptr(pttype, "dos");

        if (!is_gpt && !is_mbr) {
                log_error("No GPT or MBR partition table discovered on\n"
                          "    %s\n"
                          PARTITION_TABLE_BLURB, arg_image);
                return -EINVAL;
        }

        errno = 0;
        pl = blkid_probe_get_partitions(b);
*/
	return 0;
}
