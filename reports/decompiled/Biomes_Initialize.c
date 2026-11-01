
void Biomes__Initialize(undefined8 param_1)

{
  longlong lVar1;
  
  if (DAT_18305faed == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    DAT_18305faed = '\x01';
  }
  if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  if (DAT_18305faee == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    FUN_1802334a0(&DAT_182ee2698);
    FUN_1802334a0(&DAT_182ee24f0);
    FUN_1802334a0(&DAT_182eee7b0);
    DAT_18305faee = '\x01';
  }
  lVar1 = thunk_FUN_1802a5470(DAT_182eee7b0);
  if (lVar1 != 0) {
    FUN_1810c1fc0(lVar1,DAT_182ee24f0);
    FUN_1810e28d0(lVar1,0,0x3fc00000,DAT_182ee2698);
    FUN_1810e28d0(lVar1,1,0x3fa66666,DAT_182ee2698);
    FUN_1810e28d0(lVar1,2,0x3f99999a,DAT_182ee2698);
    FUN_1810e28d0(lVar1,3,0x3fb33333,DAT_182ee2698);
    FUN_1810e28d0(lVar1,4,0x3fcccccd,DAT_182ee2698);
    if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
      il2cpp_runtime_class_init(DAT_182ea1000);
    }
    *(longlong *)(*(longlong *)(DAT_182ea1000 + 0xb8) + 0x78) = lVar1;
    FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8) + 0x78,lVar1);
    Biomes__LoadBiomeResourcesFromJson(param_1,0);
    return;
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

