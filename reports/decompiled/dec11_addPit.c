
void HeightMapGenerator__addPit
               (undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
               undefined8 param_5)

{
  int iVar1;
  undefined8 local_48;
  undefined8 local_40;
  undefined8 uStack_38;
  undefined8 local_30 [2];
  
  local_30[0] = 0;
  local_40 = 0;
  uStack_38 = 0;
  local_48 = param_1;
  FUN_180232f70(&local_48,param_1);
  local_40 = param_3;
  FUN_180232f70(&local_40,param_3);
  uStack_38 = param_4;
  FUN_180232f70(&uStack_38,param_4);
  local_30[0] = param_5;
  FUN_180232f70(local_30);
  for (iVar1 = RandomUtils__GetNumberInRange(param_2,0); 0 < iVar1; iVar1 = iVar1 + -1) {
    HeightMapGenerator__<addPit>g__addOnePit_14_0(param_1,&local_48,0);
  }
  return;
}

