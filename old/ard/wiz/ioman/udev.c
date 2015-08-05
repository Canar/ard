#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <linux/stat.h>
#include <linux/fcntl.h>
#include <blkid/blkid.h>
#include <unistd.h>
#include <libudev.h>

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

#define error_message_1 "Out of memory allocating %s."
#define error_message_2 "Invalid invocation of %s."

#define test_general(cond,out,msg,...) \
	if( cond ) { \
		printf( #cond " failed in %s at line %i.\n" #msg , __FILE__ , __LINE__ , ##__VA_ARGS__ ); \
		out; \
	} \

#define test_generic(cond,out,...) test_general(cond,out,"")
#define test_standard(cond,msgno,...) test_general(cond,return msgno,error_message_ ##msgno, ##__VA_ARGS__)

#define test_alloc(assignment) test_standard( !( assignment ) , 1 )
#define test_args test_standard( argc != 2 , 2 , argv[0], argc )

#define annihilate(...)

#define defer(...) __VA_ARGS__ _bi0()
#define dupe(...) __VA_ARGS__ , ##__VA_ARGS__
#define bit(a,...) _bi ##a ( __VA_ARGS__ ) 
#define _bi0(...)
#define _bi1(...) __VA_ARGS__
#define _bin(d,...) __VA_ARGS__ _bi1(__VA_ARGS__)
#define _a _b _b
#define _b _c _c
#define _c _d _d
#define _d _e _e
#define _e _a _a

#define mg( a, ... ) #a ": %s\n"  __VA_ARGS__, udev_device_get_ ##a (d)

#define multi_get(what,inside) "%s\n" inside , udev_device_get_ ##what (d)
//need better system for assertion
int main(int argc, const char *argv[]) {
        struct udev *udev = NULL;
	struct stat st;
	int fd;
        struct udev_device *d = NULL;

	test_args

	test_alloc( udev = udev_new() )

	// if (fstat(fd, &st) < 0)return 4; //return log_error_errno(errno, "Failed to stat block device: %m");
	test_alloc( d=udev_device_new_from_syspath(udev, argv[1]) )

	printf( mg(devpath, mg(subsystem, mg(devtype, mg(syspath, mg(sysname, mg(sysnum, mg(devnode, ""))))))) );

//	printf( multi_get(devpath, multi_get(devtype,"") ) )
				
//				) );
/*		multi_get(subsystem,
		multi_get(devtype,
		multi_get(syspath,
		multi_get(sysname
		multi_get(sysnum,
		multi_get(devnode,
	""))))))) ); */

	return 0;
}
