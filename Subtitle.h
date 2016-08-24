#import <Foundation/Foundation.h>

#define START	1
#define END		0
#define BUFFER_BASE_SIZE 102400
#define BUFFER_LINE_SIZE 1024
#define TEMP_STRING_SIZE 256

typedef struct subtitle {
	long startTime;
	long endTime;
	char *subtitleContentPointer;
	struct subtitle* next;
	struct subtitle* pre;
}linkNode, *subtitleLinkPointer;

@interface Subtitle : NSObject {
@private 
	char *allLine;
	char *freeAllLine;
	char *tempString;
	subtitleLinkPointer head;
	subtitleLinkPointer linkList;
	subtitleLinkPointer currentNodePointer;
	subtitleLinkPointer temp;	
}

@property char *allLine;
@property char *freeAllLine;
@property char *tempString;
@property subtitleLinkPointer head;
@property subtitleLinkPointer linkList;
@property subtitleLinkPointer currentNodePointer;
@property subtitleLinkPointer temp;

- (long) stringToLong:(char *)line timeFlag: (BOOL)flag;
- (BOOL) deleteLastLine:(char *)s;
- (int) getLine: (char *)lineBuffer;
- (BOOL) initWithFilePath: (char *)filePath;
- (char *) getSubtitle: (long)time;
@end
