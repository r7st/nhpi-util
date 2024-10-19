function ReadPrices(){
  Type="null"
  i=1;
  while(getline < "charts.csv"){
    if (match($0, "^#[a-z]+")) {
      Type=substr($0, RSTART+1, 1)
      Prices[Type "SIZE"]=1
      i=1
      continue
    }
    sub("# "Type, "", Line)
    Prices[Type i++]=$0
    Prices[Type "SIZE"]++
  }
}

function GetBuyPrice(Val, Inp){
  sub("[(]", ",", Val)
  sub("[/]", ",", Val)
  sub("[)]", "", Val)
  if (sub("s$", "", Inp)) sub("^[0-9]+,", "", Val)
  else sub(",[0-9]+$", "", Val)
  ValReg="(^|,)"Inp"(,|$)"
  if (match(Val, ValReg)) return 1
  return 0
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

function GetBuyPrices(Cha, Type, Inp){
  ChaInd=GetChaIndex(Cha)
  for (i=1; i<=Prices[Type "SIZE"]; i++){
    Vals=GetBuyVal(Prices[Type i])
    split(Vals, LineVal, ";")
    if (GetBuyPrice(LineVal[ChaInd], Inp)){
      match(Prices[Type i], "^[^;]+")
      BaseCost=substr(Prices[Type i], RSTART, RLENGTH)
      match(Prices[Type i], "[^;]+$")
      Items=substr(Prices[Type i], RSTART, RLENGTH)
      printf("bc%-3s %s\n", BaseCost, Items)
    }
  }
}

function IdentifyFromBuyPrice(Inp){
  Type="null"; Cha="null"
  sub("^b", "", Inp)
  match(Inp, "^[0-9]+"); Cha=substr(Inp, RSTART, RLENGTH)
  sub("^[0-9]+", "", Inp)
  match(Inp, "^[spbcrwk]"); Type=substr(Inp, RSTART, RLENGTH)
  sub("^[a-z]", "", Inp)
  GetBuyPrices(int(Cha), Type, Inp)
}

function IdentifyFromSellPrice(Inp){
  sub("^s", "", Inp)
  Type=substr(Inp, 1, 1); sub("^.", "", Inp)
  ValReg="(^|,)"Inp"(,|$)"
  for (i=1; i<Prices[Type "SIZE"]; i++){
    split(Prices[Type i], Vals, ";")
    Val=Vals[9]; sub("[(]", ",", Val); sub("[)]", "", Val)
    if (match(Val, ValReg)) {
      printf("bc%-3s %s\n", Vals[1], Vals[10])
    }
  }
}

BEGIN{ print "Starting nhpi-util..."; ReadPrices() }
/^q/{ print "Exiting..."; exit }
/^#/{ next }
/^b/{ IdentifyFromBuyPrice($0) }
/^s/{ IdentifyFromSellPrice($0) }
