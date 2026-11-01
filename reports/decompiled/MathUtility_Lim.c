
void MathUtility__Lim(undefined4 param_1)

{
  undefined4 uVar1;
  
  if (DAT_18305fe7b == '\0') {
    FUN_1802334a0(&DAT_182e7eb28);
    DAT_18305fe7b = '\x01';
  }
  if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  uVar1 = System_Math__Max(param_1,0,0);
  System_Math__Min(uVar1,0x4059000000000000,0);
  return;
}

