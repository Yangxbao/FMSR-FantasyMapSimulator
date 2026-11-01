
void HeightMapExternal__Generate(longlong param_1)

{
  longlong lVar1;
  
  if (DAT_18305fb95 == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182ebcc80);
    DAT_18305fb95 = '\x01';
  }
  if ((*(longlong *)(param_1 + 0x18) != 0) && (*(longlong *)(param_1 + 0x20) != 0)) {
    lVar1 = *(longlong *)(param_1 + 0x20);
                    /* WARNING: Could not recover jumptable at 0x00018038b760. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (**(code **)(lVar1 + 0x18))(*(undefined8 *)(lVar1 + 0x40),*(undefined8 *)(lVar1 + 0x28));
    return;
  }
  if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  UnityEngine_Debug__LogError(DAT_182ebcc80,0);
  return;
}

