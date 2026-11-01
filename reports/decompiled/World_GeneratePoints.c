
undefined8 World__GeneratePoints(longlong param_1)

{
  int iVar1;
  int iVar2;
  undefined8 uVar3;
  int iVar4;
  double dVar5;
  double dVar6;
  undefined1 unaff_XMM7 [16];
  undefined1 auVar7 [16];
  
  if (DAT_183060fb2 == '\0') {
    FUN_1802334a0(&DAT_182e7eb28);
    DAT_183060fb2 = '\x01';
  }
  iVar1 = *(int *)(param_1 + 0x138);
  iVar4 = *(int *)(param_1 + 0x13c);
  iVar2 = *(int *)(param_1 + 0x140);
  if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  iVar4 = iVar4 * iVar1;
  auVar7._0_8_ = (double)(iVar4 / iVar2);
  auVar7._8_8_ = 0;
  if (auVar7._0_8_ < 0.0) {
    dVar6 = (double)FUN_1802d2fa0(auVar7._0_8_,(longlong)iVar4 % (longlong)iVar2 & 0xffffffff);
  }
  else {
    auVar7 = sqrtpd(unaff_XMM7,auVar7);
    dVar6 = auVar7._0_8_;
  }
  if (DAT_183060fad == '\0') {
    FUN_1802334a0(&DAT_182e7eb28);
    DAT_183060fad = '\x01';
  }
  if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  dVar5 = (double)thunk_FUN_180274ab0(0x4024000000000000,0x4000000000000000,0);
  dVar6 = (double)FUN_180005fd0(dVar6 * dVar5);
  *(double *)(param_1 + 0x248) = dVar6 / dVar5;
  uVar3 = World__GetJitteredGrid(param_1);
  *(undefined8 *)(param_1 + 600) = uVar3;
  FUN_180232f70(param_1 + 600,uVar3);
  uVar3 = FUN_1802d10b0(((*(double *)(param_1 + 0x248) * 0.5 + (double)*(int *)(param_1 + 0x138)) -
                        1e-10) / *(double *)(param_1 + 0x248));
  *(undefined8 *)(param_1 + 0x238) = uVar3;
  uVar3 = FUN_1802d10b0(((*(double *)(param_1 + 0x248) * 0.5 + (double)*(int *)(param_1 + 0x13c)) -
                        1e-10) / *(double *)(param_1 + 0x248));
  *(undefined8 *)(param_1 + 0x240) = uVar3;
  return *(undefined8 *)(param_1 + 600);
}

