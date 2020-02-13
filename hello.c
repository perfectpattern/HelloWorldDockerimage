#include <sys/syscall.h>
#include <unistd.h>

#ifndef DOCKER_IMAGE
	#define DOCKER_IMAGE "hello-world"
#endif

#ifndef DOCKER_ARCH
	#define DOCKER_ARCH "amd64"
#endif

const char message[] =
	"\n"
	"Hello from Perfect Pattern!\n"
	"This message shows that your installation appears to be working correctly!\n"
	"\n"
	"\n";

int main() {
	//write(1, message, sizeof(message) - 1);
	syscall(SYS_write, STDOUT_FILENO, message, sizeof(message) - 1);

	//_exit(0);
	//syscall(SYS_exit, 0);
	return 0;
}
