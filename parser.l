
alpha 			[A-Za-z_]
fl			(f|F|l|L)
ul			(u|U|l|L)*
digit 			[0-9]
space 			[ ]
hex			[a-fA-F0-9]
exp			[Ee][+-]?{digit}+

%{
char datatype[100] = "dummy";
int tl;
char next;
#include <stdio.h>
#include <string.h> 
%}

%%	
\n   { yylineno++; }
"/*"					{ multicomment(); }
"//"					{ singlecomment(); }

"#include<"({alpha})*".h>" {}

"#define"({space})""({alpha})""({alpha}|{digit})*""({space})""({digit})+"" 			{ return DEFINE;}
"#define"({space})""({alpha}({alpha}|{digit})*)""({space})""(({digit}+)\.({digit}+))"" 		{ return DEFINE;}
"#define"({space})""({alpha}({alpha}|{digit})*)""({space})""({alpha}({alpha}|{digit})*)"" 	{ return DEFINE;}

{digit}+    				{  insertToConstTable(yytext, yylineno, "INT"); return CONSTANT; }
({digit}+)\.({digit}+) 			{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
0[xX]{hex}+{ul}?			{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}+{ul}?				{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
'(\\.|[^\\'])+'				{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}+{exp}{fl}?			{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}*"."{digit}+({exp})?{fl}?	{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }
{digit}+"."{digit}*({exp})?{fl}?	{  insertToConstTable(yytext, yylineno, "FLOAT"); return CONSTANT; }

{alpha}?\"(\\.|[^\\"])*\"		{  insertToConstTable(yytext, yylineno, "STRING"); return STRING_LITERAL; } 

"->"			{  return PTR_OP; }
"++"			{  return INC_OP; }
"--"			{  return DEC_OP; }
"<<"			{  return LEFT_OP; }
">>"			{  return RIGHT_OP; }
"<="			{  return LE_OP; }
">="			{  return GE_OP; }
"=="			{  return EQ_OP; }
"!="			{  return NE_OP; }
"&&"			{  return AND_OP; }
"||"			{  return OR_OP; }
"*="			{  return MUL_ASSIGN; }
"/="			{  return DIV_ASSIGN; }
"%="			{  return MOD_ASSIGN; }
"+="			{  return ADD_ASSIGN; }
"-="			{  return SUB_ASSIGN; }
"<<="			{  return LEFT_ASSIGN; }
">>="			{  return RIGHT_ASSIGN; }
"&="			{  return AND_ASSIGN; }
"^="			{  return XOR_ASSIGN; }
"|="			{  return OR_ASSIGN; }

"auto"			{ return AUTO; }
"break"			{ return BREAK; }
"case"			{ return CASE; }
"char"			{ return CHAR; }
"const"			{ return CONST; }
"continue"		{ return CONTINUE; }
"default"		{ return DEFAULT; }
"do"			{ return DO; }
"double"		{ return DOUBLE; }
"else"			{ return ELSE; }
"enum"			{ return ENUM; }
"extern"		{ return EXTERN; }
"float"			{ strcpy(datatype, "FLOAT"); tl = yylineno; return FLOAT; }
"for"			{ return FOR; }
"goto"			{ return GOTO; }
"if"			{ return IF; }
"int"			{ strcpy(datatype, "INT"); tl = yylineno; return INT; }
"long"			{ return LONG; }
"register"		{ return REGISTER; }
"return"		{ return RETURN; }
"short"			{ return SHORT; }
"signed"		{ return SIGNED; }
"sizeof" 		{ return SIZEOF; }
"static"		{ return STATIC; }
"struct"		{ return STRUCT; }
"switch"		{ return SWITCH; }
"typedef"		{ return TYPEDEF; }
"union"			{ return UNION; }
"unsigned"		{ return UNSIGNED; }
"void"			{ return VOID; }
"volatile"		{ return VOLATILE; }
"while"			{ return WHILE; }


";"			{  strcpy(datatype, "dummy"); return(';'); }
("{"|"<%")		{  return('{'); }
("}"|"%>")		{  return('}'); }
","			{  return(','); }
":"			{  return(':'); }
"="			{  return('='); }
"("			{  return('('); }
")"			{  return(')'); }
("["|"<:")		{  return('['); }
("]"|":>")		{  return(']'); }
"."			{  return('.'); }
"&"			{  return('&'); }
"!"			{  return('!'); }
"~"			{  return('~'); }
"-"			{  return('-'); }
"+"			{  return('+'); }
"*"			{  return('*'); }
"/"			{  return('/'); }
"%"			{  return('%'); }
"<"			{  return('<'); }
">"			{  return('>'); }
"^"			{  return('^'); }
"|"			{  return('|'); }
"?"			{  return('?'); }
"printf"|"scanf"	{ insertToHash(yytext,"PROCEDURE",yylineno); return IDENTIFIER; }
"main" 			{ insertToHash(yytext,"PROCEDURE",yylineno); return IDENTIFIER; }
{alpha}({alpha}|{digit})*    		{  
						if(strcmp(datatype, "dummy")==0)
							return IDENTIFIER;
						else 
						{
							insertToHash(yytext,datatype,yylineno);
							return IDENTIFIER; 
						}
					}
[ \t\v\n\f]		{  }
.			{ /* IG chars */ }
%%

struct cnode
{
	char num[50];
	char type[20];
};
struct cnode ctable[100];
int ccount = 0;

void insertToConstTable(char *num, int l, char *type)
{
	strcpy(ctable[ccount].num, num);
	strcpy(ctable[ccount].type, type);
	ccount++;
}

void disp()
{
	int i;
	printf("\n|=======================================|");	
	printf("\n|---------------------------------------|");
	printf("\n|Variable and types \t\t\t|\n");
	printf("|---------------------------------------|\n");
	printf("|Value \t\t|\tType \t\t|\n");
	printf("|---------------------------------------|\n");
	for(i=0;i<ccount;i++)
	{
		printf("*");
		printf("%s\t\t", ctable[i].num);
		printf("|\t");
		printf("%s\t\t\n", ctable[i].type);
	}
	printf("|---------------------------------------|\n");	
	printf("\n\n");
}

struct node
{
	char token[100];
    	char attr[100];
    	int line_count;
	struct node *next;
};

struct hash
{
	struct node *head;
	int hash_count;
};

struct hash hashTable[1000];
int eleCount = 1000;

struct node * createNode(char *token, char *attr, int l)
{
	struct node *newnode;
	newnode = (struct node *) malloc(sizeof(struct node));
	strcpy(newnode->token, token);
	strcpy(newnode->attr, attr);
	newnode->line_count = 1; 
	newnode->next = NULL;
	return newnode;
}

int hashIndex(char *token)
{
	int hi=0;
	int l,i;
	for(i=0;token[i]!='\0';i++)
	{
		hi = hi + (int)token[i];
	}
	hi = hi%eleCount;
	return hi;
}

void insertToHash(char *token, char *attr, int l)
{
	int flag=0;
	int hi;
	hi = hashIndex(token);
	struct node *newnode = createNode(token, attr, l);
	if (hashTable[hi].head==NULL)
	{
		hashTable[hi].head = newnode;
	        hashTable[hi].hash_count = 1;
	        return;
	}
	struct node *myNode;
    	myNode = hashTable[hi].head;
	while (myNode != NULL)
    	{
        	if (strcmp(myNode->token, token)==0)
        	{
            		flag = 1;
            		if(strcmp(myNode->attr, attr)!=0)
            		{
            			strcpy(myNode->attr, attr);
            		}
            		break;
        	}
        	myNode = myNode->next;
    	}
	if(!flag)
	{
		newnode->next = (hashTable[hi].head);
		hashTable[hi].head = newnode;
		hashTable[hi].hash_count++;
	}
	return;
}

void display()
{
    	struct node *myNode;
    	int i,j, k=1;
	printf("|---------------------------------------|");
    	printf("\n|Token and Types \t\t\t|\n");
    	printf("|---------------------------------------|");
    	printf("\n|Parsed Token \t|\t Type \t\t|\n");
        printf("|---------------------------------------|\n");
    	for (i = 0; i < eleCount; i++)
    	{
        	if (hashTable[i].hash_count == 0)
            		continue;
        	myNode = hashTable[i].head;
        	if (!myNode)
            		continue;
        	while (myNode != NULL)
        	{
			printf("*");
            		printf("%s\t\t", myNode->token);
			printf("|\t");
            		printf("%s\t\t\t", myNode->attr);
            		printf("\n");
            		myNode = myNode->next;
        	}
	}
	printf("|---------------------------------------|\n");
   	return;
}

yywrap()
{
	return(1);
}
multicomment()
{
	char c, c1;
	while ((c = input()) != '*' && c != 0);
	c1=input();
	if(c=='*' && c1=='/')
	{
		c=0;
	}
	if (c != 0)
		putchar(c1);
}
singlecomment()
{
	char c;
	while(c=input()!='\n');
	if(c=='\n')
		c=0;
	if(c!=0)
		putchar(c);
}
