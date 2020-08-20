function [nf,nv,nn,valide]=valide_FVN(f,v,n,debug)
% ========================================================
% Validation des matrices FVN (facets, vertices, normales)
% ========================================================
  valide=false;
  s=0;
  [nf,d]=size(f);
  if d==3 && nf>3
    [nn,d]=size(n);
    if d==3 && nn==nf
      [nv,d]=size(v);
      if d==3 && nv>3
        valide=true;
      else
        s='Invalid Vertex Matrix (nv x 3)!';
      end
    else
      s='Invalid Normal Matrix (nn x 3)!';
    end
  else
    s='Invalid Facet Matrix (nf x 3)!';
  end
  if debug && (~valide)
    disp(s);
  end
end
