#(C) Graham Ellis, 2005-2006

#####################################################################
InstallGlobalFunction(TwistedTensorProduct,
function(R,S,EhomG,GmapE,NhomE,NEhomN,EltsE,Mult,InvE)
local   
		DimensionR,BoundaryR,HomotopyR,EltsR,
		DimensionS,BoundaryS,HomotopyS,EltsS,
		Dimension,Boundary,Homotopy,
		DimPQ,
		Int2Pair, Pair2Int,
		Htpy, CompHtpy,
		Del, CompDel, DelRecord,
		PseudoBoundary,
		Charact,
		AddWrds,
		i,j,k,l,n,p,q,r;

DimensionR:=R.dimension;
DimensionS:=S.dimension;
BoundaryR:=R.boundary;
BoundaryS:=S.boundary;
HomotopyR:=R.homotopy;
HomotopyS:=S.homotopy;
n:=Minimum(EvaluateProperty(R,"length"),EvaluateProperty(S,"length"));

if EvaluateProperty(R,"characteristic")=0
and EvaluateProperty(S,"characteristic")=0
then Charact:=EvaluateProperty(R,"characteristic");
fi;

if EvaluateProperty(R,"characteristic")=0
and EvaluateProperty(S,"characteristic")>0
then Charact:=EvaluateProperty(S,"characteristic");
fi;

if EvaluateProperty(R,"characteristic")>0
and EvaluateProperty(S,"characteristic")=0
then Charact:=EvaluateProperty(R,"characteristic");
fi;

if EvaluateProperty(R,"characteristic")>0
and EvaluateProperty(S,"characteristic")>0
then Charact:=Product(Intersection([
DivisorsInt(EvaluateProperty(R,"characteristic")),
DivisorsInt(EvaluateProperty(S,"characteristic"))
]));
fi;


if Charact=0 then AddWrds:=AddWords; else
	AddWrds:=function(v,w);
	return AddWordsModP(v,w,Charact);
	end;
fi;


#####################################################################
Dimension:=function(i)
local D,j;
if i=0 then return 1; else
D:=0;

for j in [0..i] do
D:=D+DimensionR(j)*DimensionS(i-j);
od;

return D; fi;
end;
#####################################################################

#####################################################################
DimPQ:=function(p,q)
local D,j;

if (p<0) or (q<0) then return 0; fi;

D:=0;
for j in [0..q] do
D:=D+DimensionR(p+q-j)*DimensionS(j);
od;

return D;
end;
#####################################################################

#####################################################################
Int2Pair:=function(i,p,q)       #Assume that x<=DimR(p)*DimS(q).
local s,r,x;
                           	#The idea is that the generator f_i in F
				#corresponds to a tensor (e_r x e_s)
x:=AbsoluteValue(i)-DimPQ(p+1,q-1);     #with e_r in R_p, e_s in S_q. If we
s:= x mod DimensionS(q);                #input i we get output [r,s].
r:=(x-s)/DimensionS(q);

if s=0 then return [SignInt(i)*r,DimensionS(q)];
else return [SignInt(i)*(r+1),s]; fi;

end;
#####################################################################

#####################################################################
Pair2Int:=function(x,p,q)
local y;                        #Pair2Int is the inverse of Int2Pair.

y:=[AbsoluteValue(x[1]),AbsoluteValue(x[2])];
return SignInt(x[1])*SignInt(x[2])*((y[1]-1)*DimensionS(q)+y[2]+DimPQ(p+1,q-1));end;
#####################################################################

#####################################################################
Htpy:=function(p,q,x)
local p2i, i2p, tensor, t,g, r, s;

p2i:= Pair2Int;
i2p:= Int2Pair;
tensor:=i2p(x[1],p,q);

g:=NEhomN(Mult(InvE(GmapE(EhomG(x[2]))),x[2] ));
t:=GmapE(EhomG(x[2]));
r:=HomotopyS(q,[tensor[2],g]);
s:=List(r,y->[y[1],NhomE(y[2])]);
return List(s,y->[p2i([tensor[1],y[1]],p,q+1),Mult(t,y[2])]);
end;
#####################################################################

#####################################################################
CompHtpy:=function(p,q,b)
local w, r;

r:=[];
for w in b do
r:=AddWrds(Htpy(p,q,w),r);
od;

return r;
end;
#####################################################################

#####################################################################
Del:=function(k,p,q,x)
local b,i,r,v,w,tensor,p2i,i2p,Record;  #Assume that 1 <= x <= DimR(p)*DimS(q)

if not DelRecord[k+1][p+1][q+1][AbsoluteValue(x)] = 0 then 
    if SignInt(x)=1 then return DelRecord[k+1][p+1][q+1][AbsoluteValue(x)]; 
    else return NegateWord( DelRecord[k+1][p+1][q+1][AbsoluteValue(x)] );
    fi;
fi;

	#############################################################
	Record:=function();
	if SignInt(x)=1 then
	DelRecord[k+1][p+1][q+1][AbsoluteValue(x)]:=v;
	else
	DelRecord[k+1][p+1][q+1][AbsoluteValue(x)]:=NegateWord(v);
	fi;
	end;
	#############################################################

p2i:= Pair2Int;
i2p:= Int2Pair;
tensor:=i2p(x,p,q);

if k=0 then
   b:=BoundaryS(q,tensor[2]);
   v:= List(b,v->[p2i([tensor[1],v[1]],p,q-1),NhomE(v[2])]);
   Record();
   return v;
fi;

if k=1 then
   if q=0 then
         if p>0 then
            b:=StructuralCopy(BoundaryR(p,-tensor[1]));
            v:=List(b,v->[p2i([v[1],tensor[2]],p-1,q),GmapE(v[2])]);
	    Record();
	    return v;
	 else return []; 
	 fi;
   else
         if p>0 then
            v:=CompHtpy(p-1,q-1,CompDel(1,p,q-1,Del(0,p,q,-x)));
	    Record();
	    return v;
         else return []; 
	 fi;
   fi;
fi;

if k>1 then
    if p>(k-1) then
       r:=[];
       for i in [1..k] do
       r:=AddWrds(CompDel(i,p-k+i,q+k-i-1,Del(k-i,p,q,-x)),r);
       od;
       v:= CompHtpy(p-k,q+k-2,r);
       Record();
       return v;
    else return [];
    fi;
fi;

end;
#####################################################################

#####################################################################
CompDel:=function(k,p,q,b)
local r,v,w,x, map;

map:=function(x);
return Del(k,p,q,x);
end;

r:=[];
for v in b do
w:=StructuralCopy(map(v[1]));
Apply(w,y->[y[1],Mult(v[2],y[2])]);
r:=AddWrds(w,r);
od;

return r;
end;
#####################################################################

DelRecord:=[];
for l in [0..n] do
DelRecord[l+1]:=[];
for p in [0..n] do
DelRecord[l+1][p+1]:=[];
for q in [0..n-p] do
DelRecord[l+1][p+1][q+1]:=[];
for j in [DimPQ(p+1,q-1)+1..DimPQ(p,q)] do
DelRecord[l+1][p+1][q+1][j]:=0;
od;
od;
od;
od;

PseudoBoundary:=[];
for k in [1..n] do
PseudoBoundary[k]:=[];
   for q in [0..k] do
   p:=k-q;
      for j in [DimPQ(p+1,q-1)+1..DimPQ(p,q)] do
      r:=[];
         for l in [0..p] do
         r:=AddWrds(Del(l,p,q,j),r);
         od;
         Append(PseudoBoundary[k],[r]);
      od;
  od;
od;


#####################################################################
Boundary:=function(k,j);
if k=0 then return []; 
else
	if SignInt(j)=1 then return PseudoBoundary[k][j]; 
	else return NegateWord(PseudoBoundary[k][-j]);
	fi;
fi;
end;
#####################################################################

return rec(
	    dimension:=Dimension, 
	    boundary:=Boundary, 
	    homotopy:=fail, 
	    elts:=EltsE, 
	    group:=Group(EltsE),
	    properties:=
	    [["type","resolution"],
	     ["length",n],
	     ["characteristic",Charact] ]);
end);
#####################################################################

