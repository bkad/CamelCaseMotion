/* mkvimball.c: this program makes vimballs (vim's .vba format)
 *   Author: Charles E. Campbell, Jr.
 *   Date:   Feb 28, 2008
 */

/* ---------------------------------------------------------------------
 * Includes: {{{1
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ------------------------------------------------------------------------
 * Definitions: {{{1
 */
#define BUFSIZE	1024

/* ------------------------------------------------------------------------
 * Typedefs: {{{1
 */

/* ------------------------------------------------------------------------
 * Local Data Structures: {{{1
 */

/* ------------------------------------------------------------------------
 * Global Data: {{{1
 */

/* ------------------------------------------------------------------------
 * Explanation: {{{1
 */

/* ------------------------------------------------------------------------
 * Prototypes: {{{1
 */
int main( int, char **);       /* mkvimball.c */
void MkVimball(FILE *,char *); /* mkvimball.c */

/* ------------------------------------------------------------------------
 * Functions: {{{1
 */

/* main: {{{2 */
int main(
  int    argc,
  char **argv)
{
int   iarg;
FILE *fp;
char *dot;
char  vimballname[BUFSIZE];

if(argc < 2) {
	fprintf(stderr,"***error*** (mkvimball) Usage: mkvimball vimballfile [path1 path2 ...]\n");
	exit(1);
	}
dot= strchr(argv[1],'.');
if(dot) {
	fprintf(stderr,"***error*** (mkvimball) Usage: mkvimball vimballfile [path1 path2 ...]   (vimballfile should have no '.' in it)\n");
	exit(1);
	}
sprintf(vimballname,"%s.vba",argv[1]);
fp= fopen(vimballname,"w");
if(!fp) {
	fprintf(stderr,"***error*** (mkvimball) unable to open <%s> for writing\n",vimballname);
	exit(1);
	}

/* write standard preamble to vimball */
fprintf(fp,"\" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.\n");
fprintf(fp,"UseVimball\n");
fprintf(fp,"finish\n");

/* append path, line count, and file contents to vimball */
if(argc > 2) for(iarg= 2; iarg < argc; ++iarg) MkVimball(fp,argv[iarg]);
else {
	static char buf[BUFSIZE];
	char *b;
	while(1) {
		printf("Enter path: ");
		if(!fgets(buf,BUFSIZE,stdin)) break;
		b= strchr(buf,'#');
		if(b && *b) continue; /* skip lines with #... on them (ie. treat as comment) */
		if(!strcmp(buf,"q") || !strcmp(buf,"quit")) break;
		MkVimball(fp,buf);
		}
	}

/* close vimball and return */
fclose(fp);
return 0;
}

/* --------------------------------------------------------------------- */
/* MkVimball: this function {{{2 */
void MkVimball(FILE *fp,char *path)
{
FILE          *fppath  = NULL;
unsigned long  linecnt;
int            ic;

fppath= fopen(path,"r");
if(!fppath) {
	fprintf(stderr,"***warning*** (MkVimball) unable to open file<%s>\n",path);
	return;
	}
fprintf(fp,"%s\t[[[1\n",path);

/* count lines in file */
linecnt= 0L;
while((ic= fgetc(fppath)) != EOF) if(ic == '\n') ++linecnt;
rewind(fppath);
fprintf(fp,"%lu\n",linecnt);

/* copy file into vimball */
while((ic= fgetc(fppath)) != EOF) fputc(ic,fp);

fclose(fppath);
}

/* ---------------------------------------------------------------------
 * Modelines: {{{1
 * vim: fdm=marker
 */
