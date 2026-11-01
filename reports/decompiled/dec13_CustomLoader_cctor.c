
void CustomLoader___cctor(void)

{
  undefined8 uVar1;
  
  if (DAT_18305fb92 == '\0') {
    FUN_1802334a0(&DAT_182eb4e50);
    FUN_1802334a0(&DAT_182e95788);
    FUN_1802334a0(&DAT_182ecd708);
    DAT_18305fb92 = '\x01';
  }
  uVar1 = UnityEngine_Application__get_dataPath(0);
  if (*(int *)(DAT_182e95788 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  uVar1 = System_IO_Path__Combine(uVar1,DAT_182ecd708,0);
  **(undefined8 **)(DAT_182eb4e50 + 0xb8) = uVar1;
  FUN_180232f70(*(undefined8 *)(DAT_182eb4e50 + 0xb8),uVar1);
  return;
}

