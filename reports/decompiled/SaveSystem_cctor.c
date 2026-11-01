
void SaveSystem___cctor(void)

{
  longlong *plVar1;
  undefined8 uVar2;
  
  if (DAT_183060330 == '\0') {
    FUN_1802334a0(&DAT_182ead748);
    FUN_1802334a0(&DAT_182ea3140);
    DAT_183060330 = '\x01';
  }
  plVar1 = (longlong *)System_Text_Encoding__get_ASCII(0);
  if (plVar1 != (longlong *)0x0) {
    uVar2 = (**(code **)(*plVar1 + 0x268))(plVar1,DAT_182ea3140,*(undefined8 *)(*plVar1 + 0x270));
    *(undefined8 *)(*(longlong *)(DAT_182ead748 + 0xb8) + 8) = uVar2;
    FUN_180232f70(*(longlong *)(DAT_182ead748 + 0xb8) + 8,uVar2);
    *(undefined1 *)(*(longlong *)(DAT_182ead748 + 0xb8) + 0x10) = 0;
    return;
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

