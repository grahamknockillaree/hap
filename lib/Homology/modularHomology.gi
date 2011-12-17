#(C) Graham Ellis, 2005-2006

#####################################################################
#####################################################################
#####################################################################
InstallGlobalFunction(ModularHomology,
function(X,n)
local  
	Homology_Obj,
	Homology_Arr,
	HomologyAsFpGroup;


#####################################################################
#####################################################################
Homology_Obj:=function(C,n)
local
	M1, M2, 
	dim, 
	rankM1, rankM2, 
	Dimension, Boundary,
	BasisKerd1, BasisImaged2, Rels, Rank, 
	i;

if n <0 then return false; fi;
if n=0 then return [0]; fi;

Dimension:=C.dimension;
Boundary:=C.boundary;
M1:=[];
M2:=[];

for i in [1..Dimension(n)] do
M1[i]:=Boundary(n,i);
od;

BasisKerd1:=NullspaceMat(M1);

M1:=0;
for i in [1..Dimension(n+1)] do
M2[i]:=Boundary(n+1,i);
od;

BasisImaged2:=BaseMat(M2);
dim:=Length(BasisImaged2);

Rels:=[];
for i in [1..dim] do
        Rels[i]:=SolutionMat(BasisKerd1,BasisImaged2[i]);
od;

Rank:=Length(BasisKerd1) - dim;

return rec(
	   basisKerd1:=BasisKerd1,
	   rank:=Rank,
	   rels:=Rels);
end;
#####################################################################
#####################################################################


#####################################################################
#####################################################################
HomologyAsFpGroup:=function(C,n)
local
        F, H, FhomH, Rels, Fgens, Frels, IHC, HhomC, ChomH,
        Vector2Word, BasisKerd1, rel, i, j, prime, FieldToInt, one;

IHC:=Homology_Obj(C,n);
BasisKerd1:=IHC.basisKerd1;
Rels:=IHC.rels;
prime:=EvaluateProperty(C,"characteristic");

F:=FreeGroup(Length(BasisKerd1));
Fgens:=GeneratorsOfGroup(F);
Frels:=[];

one:=Elements(GaloisField(prime))[2];
#####################################################################
FieldToInt:=function(x)
local
	i;
for i in [0..prime] do
if i*one=x then return i; fi;
od;

end;
#####################################################################

#####################################################################
Vector2Word:=function(rel)
local w,i;

w:=Identity(F);
for i in [1..Length(Fgens)] do
w:=w*Fgens[i]^FieldToInt(rel[i]);
od;

return w;

end;
#####################################################################

for rel in Rels do
Append(Frels,[Vector2Word(rel)]);
od;


for i in [1..Length(Fgens)] do
Append(Frels,[Fgens[i]^prime]);
for j in [i..Length(Fgens)] do
Append(Frels,[Fgens[i]*Fgens[j]*Fgens[i]^-1*Fgens[j]^-1]);
od;
od;

H:=F/Frels;
FhomH:=GroupHomomorphismByImages(F,H,Fgens,GeneratorsOfGroup(H));

#####################################################################
HhomC:=function(w);
return BasisKerd1[w];
end;
#####################################################################


#####################################################################
ChomH:=function(v)
local w;

w:=SolutionMat(BasisKerd1,v);
w:=Vector2Word(w);
return Image(FhomH,w);
end;
#####################################################################

return rec(
            fpgroup:=H,
	    h2c:=HhomC,
	    c2h:=ChomH );
end;
#####################################################################
#####################################################################


#####################################################################
#####################################################################
Homology_Arr:=function(f,n)
local
                C,D,ChomD,
	        HC, HChomC, ChomHC, IHC,
                HD, HDhomD, DhomHD, IHD,
                HChomHD, gensHC, imageGensHC,
                x;


C:=f.source;
D:=f.target;
ChomD:=f.mapping;

IHC:=HomologyAsFpGroup(C,n);
HC:=IHC.fpgroup;
gensHC:=GeneratorsOfGroup(HC);
HChomC:=IHC.h2c;
ChomHC:=IHC.c2h;

IHD:=HomologyAsFpGroup(D,n);
HD:=IHD.fpgroup;
HDhomD:=IHD.h2c;
DhomHD:=IHD.c2h;

imageGensHC:=[];
for x in [1..Length(gensHC)] do
Append(imageGensHC,[  DhomHD(ChomD(HChomC(x),n))  ]  );
od;

HChomHD:=GroupHomomorphismByImages(HC,HD,gensHC,imageGensHC);
return HChomHD;
end;
#####################################################################
#####################################################################


				    
		

if EvaluateProperty(X,"type")="chainComplex" then
return Homology_Obj(X,n).rank; fi;

if EvaluateProperty(X,"type")="chainMap" then
return Homology_Arr(X,n); fi;

end);
#####################################################################
#####################################################################
#####################################################################
