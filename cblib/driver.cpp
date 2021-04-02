#include <stdio.h>
#include <string.h>
extern "C" void _cb_beautify(char* src, char* dest, int srclength);
int main()
{
     char *source = "#include <stdio.h>\nint main()\n{\n int i;i=0; printf (\"hello\"); return 0; }\n";
     char sourcewritable[200];
     char dest[200];
     strcpy(sourcewritable,source);
 
    printf("input source\n\n");
 
    printf("%s", sourcewritable);
     
     
    _cb_beautify(sourcewritable,dest,strlen(sourcewritable));
 
    printf("input source\n\n");
    printf("%s", sourcewritable);
    printf("Beautified source\n");
    printf("\n");
    printf("%s",dest);
    return 0;
}
