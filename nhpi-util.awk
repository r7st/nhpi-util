function ReadPrices(){
  Type="null"; i=1;
  while(getline < "charts.csv"){
    if (match($0, "^#[a-z]+")){
      Type=substr($0, RSTART+1, 1)
      i=Prices[Type "SIZE"]=1
      continue
    }
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

function GetChaIndex(Cha){
  if (Cha >= 19) return 7
  else if (Cha == 18) return 6
  else if (Cha >= 16) return 5
  else if (Cha >= 11) return 4
  else if (Cha >= 8) return 3
  else if (Cha >= 6) return 2
  else return 1
}

function GetBuyPrices(Cha, Type, Inp){
  ChaInd=GetChaIndex(Cha)
  for (i=1; i<Prices[Type "SIZE"]; i++){
    split(Prices[Type i], Vals, ";")
    if (GetBuyPrice(Vals[ChaInd+1], Inp)){
      printf("bc%-3s %s\n", Vals[1], Vals[10])
    }
  }
}

function IdentifyFromBuyPrice(Inp){
  Type="null"; Cha="null"
  sub("^b", "", Inp)
  match(Inp, "^[0-9]+"); Cha=substr(Inp, RSTART, RLENGTH)
  sub("^[0-9]+", "", Inp)
  Type=substr(Inp, 1, 1); sub("^.", "", Inp)
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

function ListByBaseCost(Inp){
  sub("^v", "", Inp)
  Type=substr(Inp, 1, 1); sub("^.", "", Inp)
  for (i=1; i<Prices[Type "SIZE"]; i++){
    split(Prices[Type i], Vals, ";")
    if (Vals[1] == Inp) print Vals[10]
  }
}

BEGIN{ print "Starting nhpi-util..."; ReadPrices() }
/^q/{ print "Exiting..."; exit }
/^#/{ next }
/^b/{ IdentifyFromBuyPrice($0) }
/^s/{ IdentifyFromSellPrice($0) }
/^v/{ ListByBaseCost($0) }
