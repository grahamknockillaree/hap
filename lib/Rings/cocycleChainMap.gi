#(C) Graham Ellis, 2005-2006

#####################################################################
#####################################################################
InstallGlobalFunction(CR_ChainMapFromCocycle,
function(R,f,p,n)
local 
	DimensionR,BoundaryR, HomotopyR, EltsG, Mult,
	map, mapgens, ChainMap, mapgensRec, m,i,g;

DimensionR:=R.dimension;
BoundaryR:=R.boundary;
HomotopyR:=R.homotopy;
EltsG:=R.elts;

mapgensRec:=[];
for m in [0..n] do
mapgensRec[m+1]:=[];
for i in [1..DimensionR(p+m)] do
mapgensRec[m+1][i]:=[];
for g in [1..Length(EltsG)] do
mapgensRec[m+1][i][g]:=0;
od;
od;
od;

#####################################################################
Mult:=function(i,j);
return Position(EltsG,EltsG[i]*EltsG[j]);
end;
#####################################################################

#####################################################################
mapgens:=function(x,m)		#R_{p+m}-->R{m} for m>=0.
local z,u,a,y;

if mapgensRec[m+1][AbsoluteValue(x[1])][x[2]]=0 then

if x[2]>1 then 
z:=ShallowCopy(mapgens([x[1],1],m));
Apply(z,b->[b[1],Mult(x[2],b[2])]);
	if x[1]>0 then 
	mapgensRec[m+1][AbsoluteValue(x[1])][x[2]]:=z;
	else
	mapgensRec[m+1][AbsoluteValue(x[1])][x[2]]:=NegateWord(z);
	fi;

return z;
fi;

   if m=0 then 
   u:= MultiplyWord(SignInt(x[1])*f[AbsoluteValue(x[1])], [[1,x[2]]]);
      if x[1]>0 then
      mapgensRec[m+1][x[1]][x[2]]:=u;
      else
      mapgensRec[m+1][-x[1]][x[2]]:=NegateWord(u);
      fi;
   return u;
   fi;

   if m>0 then y:=StructuralCopy(BoundaryR(p+m,x[1]));
   z:=map(y,m-1);
   u:=[];
      for a in z do
            u:=AddWords(HomotopyR(m-1,a),u);
      od;
      Apply(u,t->[t[1],Mult(x[2],t[2])]);
      if x[1]>0 then
            mapgensRec[m+1][x[1]][x[2]]:=u;
      else
      mapgensRec[m+1][-x[1]][x[2]]:=NegateWord(u);
      fi;
      return  u;
   fi;

else if x[1]>0 then return mapgensRec[m+1][AbsoluteValue(x[1])][x[2]];
else return NegateWord(mapgensRec[m+1][AbsoluteValue(x[1])][x[2]]); fi;
fi;

end;
#####################################################################

#####################################################################
map:=function(w,m)
local a, u,v,x,y,z;
v:=[];

   for x in w do
   v:=AddWords(mapgens(x,m),v); 
   od;

return v;
end;
#####################################################################

#####################################################################
ChainMap:=function(w);
return map(w,n);
end;
#####################################################################

return ChainMap;
end);
#####################################################################
#####################################################################
