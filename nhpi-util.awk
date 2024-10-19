BEGIN{  # parse charts file
  print "Starting nhpi-util..."
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
/^q/{ print "Exiting..."; exit }
/^v/{  # get items by base cost
  Type=substr($0, 2, 1); sub("^..", "", $0)
  for (i=1; i<Prices[Type "SIZE"]; i++){
    split(Prices[Type i], Vals, ";")
    if (Vals[1] == $0) print Vals[10]
  }
}
/^s/{  # get base cost / items by sell price
  Type=substr($0, 2, 1); sub("^..", "", $0)
  ValReg="(^|,)"$0"(,|$)"
  for (i=1; i<Prices[Type "SIZE"]; i++){
    split(Prices[Type i], Vals, ";")
    Val=Vals[9]; sub("[(]", ",", Val); sub("[)]", "", Val)
    if (match(Val, ValReg)) {
      printf("bc%-3s %s\n", Vals[1], Vals[10])
    }
  }
}
/^b/{  # get base cost / items by buy price
  sub("^b", "", $0)
  match($0, "^[0-9]+"); Cha=substr($0, RSTART, RLENGTH)
  sub("^[0-9]+", "", $0)
  Type=substr($0, 1, 1); sub("^.", "", $0)
  split("0,6,8,11,16,18,19", ChaVal, ",")  # price range index from cha
  for (i=7; i>=1; i--){
    if (int(Cha) >= int(ChaVal[i])){ ChaInd=i; break }
  }
  for (i=1; i<Prices[Type "SIZE"]; i++){  # check each base cost
    split(Prices[Type i], Vals, ";")
    if (GetBuyPrice(Vals[ChaInd+1], $0)){  # print price matches
      printf("bc%-3s %s\n", Vals[1], Vals[10])
    }
  }
}
function GetBuyPrice(Val, Inp){  # check for price match
  gsub("[(/]", ",", Val); sub("[)]", "", Val)
  if (sub("s$", "", Inp)) sub("^[0-9]+,", "", Val)  # sucker
  else sub(",[0-9]+$", "", Val)  # not sucker
  ValReg="(^|,)"Inp"(,|$)"
  if (match(Val, ValReg)) return 1
  return 0
}
