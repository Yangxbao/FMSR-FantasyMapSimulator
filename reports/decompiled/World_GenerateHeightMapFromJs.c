
void World__GenerateHeightMapFromJs(undefined8 param_1)

{
  longlong lVar1;
  char cVar2;
  
  if (DAT_183060f62 == '\0') {
    FUN_1802334a0(&DAT_182e91c98);
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182e8e658);
    FUN_1802334a0(&DAT_182ebcba8);
    DAT_183060f62 = '\x01';
  }
  World__EnsureHeightMapExternalInitialized(param_1,0);
  lVar1 = FUN_180bcc3e0(param_1,DAT_182e91c98);
  if (*(int *)(DAT_182e8e658 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  cVar2 = UnityEngine_Object__op_Equality(lVar1,0,0);
  if (cVar2 == '\0') {
    if (lVar1 != 0) {
      HeightMapExternal__Generate(lVar1,0);
      return;
    }
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  UnityEngine_Debug__LogError(DAT_182ebcba8,0);
  return;
}

