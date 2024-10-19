function ReadPrices(){
  Type="null"
  i=1;
  while(getline < "charts.txt"){ 
    if (match($0,"^# [A-Z]+")) { 
      Type=substr($0, RSTART+2, RLENGTH-2)
      Prices[Type "SIZE"]=1
      i=1
      continue
    }
    sub("# "Type, "", Line)
    Prices[Type i++]=$0
    Prices[Type "SIZE"]++
  }
}

function GetBuyVal(Inp){
  sub("^[0-9]+;", "", Inp)
  sub(";[^;]+;[^;]+$", "", Inp)
  return Inp
}

function GetChaIndex(Cha){
  if (Cha >= 19) Ind=7
  else if (Cha == 18) Ind=6
  else if (Cha >= 16) Ind=5
  else if (Cha >= 11) Ind=4
  else if (Cha >= 8) Ind=3
  else if (Cha >= 6) Ind=2
  else Ind=1
  return Ind
}

function GetPrice(Val, Inp){
  sub("[(]", ",", Val)
  sub("[/]", ",", Val)
  sub("[)]", "", Val)
  if (sub("s$", "", Inp)) sub("^[0-9]+,", "", Val)
  else sub(",[0-9]+$", "", Val)
  if (match(Val, Inp)) return 1
  return 0
}

function GetPrices(Cha, Type, Inp){
  ChaInd=GetChaIndex(Cha)
  for (i=1; i<=Prices[Type "SIZE"]; i++){
    Vals=GetBuyVal(Prices[Type i])
    split(Vals, LineVal, ";")
    if (GetPrice(LineVal[ChaInd], Inp)){
      match(Prices[Type i], "^[^;]+")
      BaseCost=substr(Prices[Type i], RSTART, RLENGTH)
      match(Prices[Type i], "[^;]+$")
      Items=substr(Prices[Type i], RSTART, RLENGTH)
      printf("bc%-3s %s\n", BaseCost, Items)
    }
  }
}

function GetType(Typec){
  if (Typec == "s"){ Type="SCROLLS" }
  else if (Typec == "p"){ Type="POTIONS" }
  else if (Typec == "b"){ Type="BOOTS" }
  else if (Typec == "c"){ Type="CLOAKS" }
  else if (Typec == "r"){ Type="RINGS" }
  else if (Typec == "w"){ Type="WANDS" }
  else if (Typec == "k"){ Type="SPELLBOOKS" }
  return Type
}

function ParseInput(Inp){
  Type="null"; Typec="null"
  if (match(Inp,"^b")){ 
    sub("^b","",Inp)
    match(Inp, "^[0-9]+"); Cha=substr(Inp, RSTART, RLENGTH)
    sub("^[0-9]+", "", Inp)
    match(Inp, "^[spbcrwk]"); Typec=substr(Inp, RSTART, RLENGTH)
    sub("^[a-z]", "", Inp)
    Type=GetType(Typec)
    GetPrices(int(Cha), Type, Inp)
  }
}

BEGIN{ ReadPrices() }
/^#/{ next }
/^q/{ exit }
{ ParseInput($0) }
