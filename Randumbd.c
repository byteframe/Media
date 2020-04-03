#include <dirent.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SLEEP_TIME 64

int bquit = 0;

struct randumb {
	int count;
	int index;
	char *link;
	const char* name;
	char **src;
	struct randumb *next;
};

void process_directory(const char *dir_str, struct randumb *r)
{
	DIR *dir = opendir(dir_str);
	struct dirent *de;
	while ((de = readdir(dir)) != NULL) {
		if (de->d_type != DT_DIR) {
			if (r->src != NULL) {
				r->src[r->index] = malloc(strlen(dir_str)+strlen(de->d_name)+2);
				strcpy(r->src[r->index], dir_str);
				strcat(r->src[r->index], "/");
				strcat(r->src[r->index], de->d_name);
				r->index++;
			} else {
				r->count++;
			}
		} else if (de->d_name[0] != '.') {
			char *dir_str2 = malloc(strlen(dir_str)+strlen(de->d_name)+2);
			strcpy(dir_str2, dir_str);
			strcat(dir_str2, "/");
			strcat(dir_str2, de->d_name);
			process_directory(dir_str2, r);
			free(dir_str2);
		}
	}
	closedir(dir);
}

void quit()
{
	bquit = 1;
}

int main(int argc, char **argv)
{
	if (argc < 3) {
		puts("error: missing input");
		return 1;
	}
	puts("randumbd started");
	struct randumb *curr, *head = NULL;
	int i, d;
	for (i = 1, d = 0; i < argc && !bquit; i++) {
		DIR *dir;
		FILE *file;
		if ((dir = opendir(argv[i])) != NULL) {
			closedir(dir);
		} else if (file = fopen(argv[i], "r")) {
			fclose(file);
			fprintf(stderr, "error: file exists %s\n", argv[i]);
			quit();
		} else if (d < i-1) {
			file = fopen(argv[i], "w");
			if (file == NULL) {
				fprintf(stderr, "error: could not create %s\n", argv[i]);
				quit();
			} else {
				fclose(file);
				remove(argv[i]);
				curr = (struct randumb*)malloc(sizeof(struct randumb));
				curr->count = 0;
				curr->index = 0;
				curr->link = (char*)malloc(strlen(argv[i])+10);
				sprintf(curr->link, "%s", argv[i]);
				curr->name = argv[i];
				curr->src = NULL;
				int p;
				for (p = d+1; p < i; p++) {
					process_directory(argv[p], curr);
				}
				curr->src = malloc(curr->count*sizeof(*curr->src));
				for (p = d+1; p < i; p++) {
					process_directory(argv[p], curr);
				}
				curr->next = head;
				head = curr;
				d = i;
			}
		} else {
			fprintf(stderr, "error: no directories for %s\n", argv[i]);
			quit();
		}
	}
	signal(SIGINT, quit);
	signal(SIGTERM, quit);
	srand(time(NULL));
	int irand;
	curr = head;
	while (!bquit) {
		while (curr) {
			remove(curr->link);
			irand = rand()%curr->count;
			sprintf(curr->link, "%s-%d.avi", curr->name, irand);
			link(curr->src[irand], curr->link);
			curr = curr->next;
		}
		curr = head;
		sleep(SLEEP_TIME);
	}
	curr = head;
	while (curr) {
		head = curr;
		curr = curr->next;
		remove(head->link);
		free(head->link);
		for (i = 0; i < head->count; i++) {
			free(head->src[i]);
		}
		free(head->src);
		free(head);
	}
	puts("randumbd stopped");
	return 0;
}

/*
#include <dirent.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SLEEP_TIME 60

int bRunning = 1;
int filecount = 0;
int fileindex = 0;
char** files = NULL;

void process_directory(const char* dir_str)
{
	DIR* dir = opendir(dir_str);
	struct dirent* dp;
	while ((dp = readdir(dir)) != NULL) {
		if (dp->d_type == DT_DIR) {
			if (strcmp(dp->d_name, ".") && strcmp(dp->d_name, "..")) {
				char* dir_str2 = malloc(strlen(dir_str)+strlen(dp->d_name)+2);
				strcpy(dir_str2, dir_str);
				strcat(dir_str2, "/");
				strcat(dir_str2, dp->d_name);
				process_directory(dir_str2);
				free(dir_str2);
			}
		} else if (strcmp(dp->d_name, "randumb")) {
			if (files != NULL) {
				files[fileindex] = malloc(strlen(dir_str)+strlen(dp->d_name)+2);
				strcpy(files[fileindex], dir_str);
				strcat(files[fileindex], "/");
				strcat(files[fileindex], dp->d_name);
				fileindex++;
			} else {
				filecount++;
			}
		}
	}
	closedir(dir);
}

void quit()
{
	bRunning = 0;
}

int main(int argc, char** argv)
{
	if (argc < 3) {
		puts("error: missing input");
		return 1;
	}
	puts("randumbd started");
	char* dest = (char*)malloc(strlen(argv[1])+16);
	sprintf(dest, "%s", argv[1]);
	FILE *file = fopen(dest, "w");
	if (file == NULL) {
		fprintf(stderr, "error: could not create %s\n", dest);
		free(dest);
		return 1;
	}
	fclose(file);
	int i;
	for (i = 2; i < argc; i++) {
		process_directory(argv[i]);
	}
	files = malloc(filecount * sizeof(*files));
	for (i = 2; i < argc; i++) {
		process_directory(argv[i]);
	}
	printf("%d files processed\n", filecount);
	signal(SIGINT, quit);
	signal(SIGTERM, quit);
	srand(time(NULL));
	while (bRunning) {
		remove(dest);
		fileindex = rand()%filecount;
		sprintf(dest, "%s-%d.avi", argv[1], fileindex);
		link(files[fileindex], dest);
		sleep(SLEEP_TIME);
	}
	remove(dest);
	free(dest);
	for (i = 0; i < filecount; i++) {
		free(files[i]);
	}
	free(files);
	puts("randumbd stopped");
	return 0;
}
*/
