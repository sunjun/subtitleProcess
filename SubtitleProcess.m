#import <Foundation/Foundation.h>
#import "Subtitle.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	//test....
	Subtitle *first = [[Subtitle alloc] init];
	[first initWithFilePath:"/Users/sunjun/Desktop/Subtitle/prison.srt"];
	for (int i = 0; i < 4939999; i += 1000) {
		printf("%s\n", [first getSubtitle:i]);
		printf("%ld--> ", first.currentNodePointer->startTime);
	}
	for (int i = 4939999; i > 0; i -= 1000) {
		printf("%s\n", [first getSubtitle:i]);
		printf("%ld--> ", first.currentNodePointer->startTime);

	}
	[first release];
    [pool drain];
    return 0;
}
