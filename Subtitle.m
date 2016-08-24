#import "Subtitle.h"

@implementation Subtitle

@synthesize allLine;
@synthesize freeAllLine;
@synthesize head;
@synthesize linkList;
@synthesize currentNodePointer;
@synthesize tempString;
@synthesize temp;

- (BOOL)initWithFilePath: (char *)filePath {
	FILE *file;
	char *lineBuffer;
	int i;
	
	if ((file = fopen(filePath, "r")) == NULL) {
		printf("Can not open the file!\n");
		return NO;
	}
	
	if ((self.allLine = malloc(BUFFER_BASE_SIZE * sizeof(char))) == NULL) {
		printf("Memory not enough!0");
		exit(1);
	}
	fread(allLine, BUFFER_BASE_SIZE, 1, file);
	
	for (i = 1; feof(file) != 1; i++) {
		if ((self.allLine = realloc(self.allLine, (BUFFER_BASE_SIZE * (i+1))*sizeof(char))) == NULL) {
			printf("Memory not enough!1");
			exit(1);
		}
		fread(self.allLine + BUFFER_BASE_SIZE * i, BUFFER_BASE_SIZE, 1, file);
	}
	fclose(file);
	
	//set mark at the end of the file
	self.allLine[strlen(self.allLine)] = -1;
	
	self.tempString = malloc(TEMP_STRING_SIZE * sizeof(char));
	memset(self.tempString, 0, sizeof(char)*TEMP_STRING_SIZE);
	
	if ((lineBuffer = malloc(BUFFER_LINE_SIZE * sizeof(char))) == NULL) {
		printf("Memory not enough!2");
		exit(1);
	}
	memset(lineBuffer, 0, BUFFER_LINE_SIZE * sizeof(char));
	self.freeAllLine = self.allLine;
	self.head = self.linkList = malloc(sizeof(linkNode));
	
	while ([self getLine:lineBuffer] != EOF) {
		
		//this line is content
		self.linkList->subtitleContentPointer = malloc(strlen(lineBuffer)*sizeof(char)+1);
		strcpy(self.linkList->subtitleContentPointer, lineBuffer);
		memset(lineBuffer, 0, BUFFER_LINE_SIZE * sizeof(char));
		
		//before create a new node, delete the last node last line
		[self deleteLastLine:self.linkList->subtitleContentPointer];
		
		//create new node
		self.temp = self.linkList;
		self.linkList = malloc(sizeof(linkNode));
		self.temp->next = self.linkList;
		self.linkList->pre = self.temp;
		
		//this line is time
		self.linkList->startTime = [self stringToLong:self.tempString timeFlag:START];
		self.linkList->endTime = [self stringToLong:self.tempString timeFlag:END];
	}
	self.linkList->next = NULL;
	self.currentNodePointer = self.head->next;
	free(lineBuffer);
	free(freeAllLine);
	
	return YES;
}

- (char *)getSubtitle: (long)time {
	if (time < self.currentNodePointer->startTime) {
		while (self.currentNodePointer->pre != self.head 
			   && time < self.currentNodePointer->pre->startTime) {
			self.currentNodePointer = self.currentNodePointer->pre;
		}
		
		if (self.currentNodePointer->pre == self.head)
			return NULL;
		else if (time >= self.currentNodePointer->pre->endTime) {
			self.currentNodePointer = self.currentNodePointer->pre;
			return self.currentNodePointer->subtitleContentPointer;
		} else
			return NULL;
		
	} else if (time > self.currentNodePointer->endTime) {
		while (self.currentNodePointer->next != NULL 
			   && time > self.currentNodePointer->next->endTime) {
			self.currentNodePointer = self.currentNodePointer->next;			
		}
		if (self.currentNodePointer->next == NULL)
			return NULL;
		else if (time >= self.currentNodePointer->next->startTime) {
			self.currentNodePointer = self.currentNodePointer->next;
			return self.currentNodePointer->subtitleContentPointer;
		}
		else
			return NULL;
		
	} else {
		return self.currentNodePointer->subtitleContentPointer;
	}
	
	return NULL;
}

- (long) stringToLong:(char *)line timeFlag: (BOOL)flag {
	long time = 0;
	int i, j = 0;
	int mask[6] = {36000, 3600, 600, 60, 10, 1};
	
	if (flag == END) {
		for (i = 0; i < 12; i++)
			line[i] = line[i + 17];
	}
	for (i = 0; i < 8; i++)
		if (line[i] >= '0' && line[i] <= '9')
			time += (line[i] - '0') * 1000 * mask[j++];
	i++;
	time += (line[i++] - '0') * 100;
	time += (line[i++] - '0') * 10;
	time += (line[i++] - '0');
	
	return time;
}

- (BOOL) deleteLastLine:(char *)s {
	int i = 0, j = 0, totalLine = 0, line = 0;
	
	if (s == NULL)
		return YES;
	
	i = strlen(s);
	while (s[j] != '\0') {
		if (s[j] == '\n')
			totalLine++;
		j++;
	}
	j = 0;
	while (s[j] != '\0' && line < totalLine - 2) {
		if (s[j] == '\n')
			line++;
		j++;
	}
	s[j] = '\0';
	return NO;
}
- (int) getLine: (char *)lineBuffer {
	
	int i = 0;
	
	memset(self.tempString, 0, TEMP_STRING_SIZE);
	while (*self.allLine != EOF) {
		if (*self.allLine != '\n') {
			self.tempString[i++] = *self.allLine++;
		} else {
			self.tempString[i] = '\n';
			if (strlen(self.tempString) == 31 && self.tempString[15] == '>') {
				self.allLine++;
				break;
			} else {
				strcat(lineBuffer, self.tempString);
				memset(self.tempString, 0, TEMP_STRING_SIZE);
				i = 0;
				self.allLine++;
			}
		}
	}
	if (*self.allLine == EOF)
		return EOF;
	return i;
}

- (void) dealloc {
	[super dealloc];
	free(tempString);
	while (self.head->next != NULL) {
		self.temp = self.head;
		self.head = self.head->next;
		free(self.temp);
	}
	free(self.head);
}

@end
