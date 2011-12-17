#(C) Graham Ellis, 2005-2006

#####################################################################
InstallGlobalFunction(ResolutionFiniteSubgroup,
function(arg)
local 
		R,gensG,gensK,
		DimensionR, BoundaryR, HomotopyR, EltsG,
		Dimension, Boundary, Homotopy, EltsK,
		G, K, TransK, sK,
		Gword2Kword, G2K, Pair2Int, Int2Pair,
		Mult;
		
if Length(arg)=3 then
R:=arg[1]; gensG:=arg[2]; gensK:=arg[3];
fi;
if Length(arg)=2 then
R:=arg[1]; gensG:=R.group; gensK:=arg[2];
fi;
				#gensG and gensK originally had to be
				#generating sets. Later I allowed them to be
				#the groups G, K themselves. Sloppy!
DimensionR:=R.dimension;
BoundaryR:=R.boundary;
HomotopyR:=R.homotopy;
EltsG:=R.elts;

if IsList(gensG) then G:=Group(gensG); else G:=gensG; fi;
if IsList(gensK) then K:=Group(gensK); else K:=gensK; fi;
EltsK:=Elements(K);
TransK:=RightTransversal(G,K);
sK:=Size(TransK);

#####################################################################
Mult:=function(i,j);
return Position(EltsG,TransK[i]*EltsG[j]);
end;
#####################################################################

#####################################################################
Dimension:=function(n);
return sK*DimensionR(n);
end;
#####################################################################

#####################################################################
G2K:=function(g)
local t,k;
t:=PositionCanonical(TransK,EltsG[g]);
k:=Position(EltsK,EltsG[g]*TransK[t]^-1);
return [k,t];
end;
#####################################################################

#####################################################################
Pair2Int:=function(x)
local i,t;
i:=x[1]; t:=x[2];
return SignInt(i)*((AbsoluteValue(i)-1)*sK + t);
end;
#####################################################################

#####################################################################
Int2Pair:=function(i)
local j,k, x;
j:=AbsoluteValue(i);
x:=j mod sK;
k:=(j-x)/sK;
if not x=0 then return [SignInt(i)*(k+1),x]; else
return [SignInt(i)*k,sK]; fi;
end;
#####################################################################

#####################################################################
Gword2Kword:=function(w)
local x, y, v;

v:=[];
for x in w do
y:=G2K(x[2]);
y:=[Pair2Int([x[1],y[2]]),y[1]];
Append(v,[y]);
od;
return v;
end;
#####################################################################

#####################################################################
Boundary:=function(n,i)
local x, w;

x:=Int2Pair(i);
w:=StructuralCopy(BoundaryR(n,x[1]));
Apply(w, y->[y[1],Mult(x[2],y[2])]);
return Gword2Kword(w);
end;
#####################################################################

return rec(
	     dimension:=Dimension,
	     boundary:=Boundary,
	     homotopy:=fail,
	     elts:=EltsK,
	     group:=K,
	     properties:=
	     [["length",EvaluateProperty(R,"length")],
	      ["characteristic",EvaluateProperty(R,"characteristic")],
	      ["reduced",false],
	      ["type","resolution"] ]);
end);
#####################################################################


