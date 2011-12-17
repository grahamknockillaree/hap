#(C) Graham Ellis, 2005-2006

#####################################################################
#####################################################################
InstallGlobalFunction(ResolutionPrimePowerGroup,
function(G,n)
local
	eltsG,
	gensG,
	Dimension,
	Boundary,
	Homotopy,
	PseudoBoundary,
	WordToVectorList,
	VectorListToWord,
	prime, pp,
	BoundaryMatrix,
	MT,
	GactZG,
	GactZGlist,
	ZGbasisOfKernel,
	one,
	InverseFlat,
	FieldToInt,
	ComplementaryBasis,
	g,h,i,x,tmp;

tmp:=SSortedList(Factors(Order(G)));
if Length(tmp)>1 then 
Print("This function can only be applied to small prime-power groups. \n");
return fail;
fi;
prime:=tmp[1];
pp:=Order(G);
one:=Identity(GaloisField(prime));

gensG:=ReduceGenerators(GeneratorsOfGroup(G),G);
eltsG:=Elements(G);
MT:=MultiplicationTable(eltsG);

PseudoBoundary:=[];
for i in [1..n] do
PseudoBoundary[i]:=[];
od;

for x in gensG do
Append(PseudoBoundary[1], [  [[-1,1],[1,Position(eltsG,x)]]  ]);
od;

#####################################################################
Dimension:=function(i);
if i<0 then return 0; fi;
if i=0 then return 1; fi;
return Length(PseudoBoundary[i]);
end;
#####################################################################

#####################################################################
Boundary:=function(i,j);
if i<0 then return []; fi;
if j>0 then
return PseudoBoundary[i][j]; 
else return
 NegateWord(PseudoBoundary[i][-j]);
 fi;
end;
#####################################################################

#####################################################################
FieldToInt:=function(x)
local i;
for i in [0..prime] do
if one*i=x then return i; fi;
od;
return fail;
end;
#####################################################################

#####################################################################
WordToVectorList:=function(w,k)	#w is a word in R_k. 
local v,x,a;			#v is a list of vectors mod p.
v:=List([1..Dimension(k)],x->List([1..pp],y->0) );

for x in w do
a:=AbsoluteValue(x[1]);
v[a][x[2]]:=v[a][x[2]] + SignInt(x[1]);
od;

return v mod prime;
end;
#####################################################################

#####################################################################
VectorListToWord:=function(v)
local w, i, x;

w:=[];
for x in [1..Length(v)] do
for i in [1..Length(v[x])] do
if not v[x][i]=0 then 
Append(w, [ [x,i]   ]);
fi;
od;
od;

return w;
end;
#####################################################################

#####################################################################
GactZG:=function(g,v)
local u,h;
u:=[];
for h in [1..Length(v)] do
u[MT[g][h]]:=StructuralCopy(v[h]);
od;
return u;
end;
#####################################################################

#####################################################################
GactZGlist:=function(g,w)
local v,gw;
gw:=[];
for v in w do
Append(gw,[GactZG(g,v)]);
od;
return gw;
end;
#####################################################################

#####################################################################
BoundaryMatrix:=function(k)	#Returns the matrix of d_k:R_k->R_k-1
local M, b, i, j,v;		
				#M is actually the transpose of the matrix!

M:=[];

for i in [1..Dimension(k)] do
v:=WordToVectorList(Boundary(k,i),k-1);
for j in [1..pp] do
M[j + (i-1)*pp]:=Flat(GactZGlist(j,v));
od;
od;

return M*one;
end;
#####################################################################


#####################################################################
InverseFlat:=function(v)
local w,x,cnt,i;

w:=[];
cnt:=0;
while cnt< Length(v) do
x:=[];
for i in [cnt+1..cnt+pp] do
Append(x,[v[i]]);
cnt:=cnt+1;
od;
Append(w,[x]);
od;
return w;
end;
#####################################################################

#####################################################################
ComplementaryBasis:=function(B)
local BC, heads,ln, i, v;

heads:=SemiEchelonMat(B).heads;
ln:=Length(B[1]);
BC:=[];

for i in [1..ln] do
if heads[i]=0 then
v:=List([1..ln], x->0*one);
v[i]:=one;
Append(BC,[v]);
fi;
od;


return BC;
end;
#####################################################################

#####################################################################
ZGbasisOfKernel:=function(k)		#The workhorse!
local  	i, v, g, h, b, ln, B, B1, B2,NS, 
	Bcomp, Bfrattini, BasInts, IF;

IF:=InverseFlat;
NS:=SemiEchelonMat(NullspaceMat(BoundaryMatrix(k)));
B:=NS.vectors;
Bcomp:=ComplementaryBasis(B);


Bfrattini:=[];
for b in B do
for g in [2..pp] do
#AddSet(Bfrattini,b-  Flat(GactZGlist(g,IF(b))));
Append(Bfrattini,[b-  Flat(GactZGlist(g,IF(b)))]);
od;
od;

if prime>2 then 
ln:=Length(B[1]);
for b in B do
for g in [2..pp] do
if Order(eltsG[g])=prime then
v:=List([1..ln],x->0);
for i in [1..prime] do
v:=v+ Flat(GactZGlist(Position(eltsG,eltsG[g]^i),IF(b)));
od;
#AddSet(Bfrattini,v);
Append(Bfrattini,v);
fi;
od;
od;
fi;

B1:=ComplementaryBasis(Concatenation(Bfrattini,Bcomp));
B2:=[];
for b in B1 do
i:=PositionProperty(b,x->(not x= (0*one)));
Append(B2, [  B[NS.heads[i]] ]);
od;

BasInts:=[];
for v in B2 do
Append(BasInts,[List(v,x->FieldToInt(x))]);
od;

return List(BasInts,v->InverseFlat(v));
end;
#####################################################################

for i in [2..n] do
for x in ZGbasisOfKernel(i-1) do
Append(PseudoBoundary[i], [VectorListToWord(x)]   );
od;
od;


return rec(
		dimension:=Dimension,
		boundary:=Boundary,
		homotopy:=fail,
		elts:=eltsG,
		group:=G,
		properties:=
			[["length",n],
			 ["reduced",true],
			 ["type","resolution"],
			 ["characteristic",prime]]);
end);
#####################################################################
#####################################################################
