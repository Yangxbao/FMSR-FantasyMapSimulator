
longlong Puerts_DefaultLoader__PathToUse(undefined8 param_1,longlong param_2)

{
  char cVar1;
  longlong lVar2;
  
  if (DAT_183064fa7 == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182ecf568);
    FUN_1802334a0(&DAT_182ece3b0);
    FUN_1802334a0(&DAT_182eef0f0);
    FUN_1802334a0(&DAT_182ecf208);
    DAT_183064fa7 = '\x01';
  }
  if (param_2 != 0) {
    cVar1 = System_String__EndsWith(param_2,DAT_182ecf208,0);
    if (cVar1 != '\0') {
      if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      UnityEngine_Debug__LogWarning(DAT_182eef0f0,0);
    }
    cVar1 = System_String__EndsWith(param_2,DAT_182ece3b0,0);
    if (cVar1 == '\0') {
      cVar1 = System_String__EndsWith(param_2,DAT_182ecf568,0);
      if (cVar1 == '\0') {
        return param_2;
      }
    }
    lVar2 = System_String__Substring(param_2,0,*(int *)(param_2 + 0x10) + -4,0);
    return lVar2;
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

