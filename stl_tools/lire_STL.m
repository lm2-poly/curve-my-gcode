function [f,v,n]=lire_STL(fid,debug)
% ==================================================
% Lecture d'un fichier STL produit par CATIA
% ==================================================
  solid_on  = 'solid CATIA STL';
  facet_on  = '  facet normal';
  facet_off = '  endfacet';
  loop_on   = '    outer loop';
  loop_off  = '    endloop';
  vertex_on = '      vertex';

  i=1; j=1;
  %disp('Fonction: lire_STL()     Version 1.0');
  if lire(fid,solid_on,debug)
    normal(i,:)=lireXYZ(fid,facet_on,debug);
    while (normal(i,:)*normal(i,:)')~=0
      lire(fid,loop_on,debug);          
      vertex(j  ,:)=lireXYZ(fid,vertex_on,debug);
      vertex(j+1,:)=lireXYZ(fid,vertex_on,debug); 
      vertex(j+2,:)=lireXYZ(fid,vertex_on,debug);
      facet(i,:) = [j,j+1,j+2]; j = j + 3;        
      lire(fid,loop_off,debug);       
      lire(fid,facet_off,debug);
      i=i+1;
      normal(i,:)=lireXYZ(fid,facet_on,debug);
    end
    if debug
      disp('endsolid CATIA STL -> OK');
    end
  end
  fclose(fid);
  v=vertex; f=facet; n=normal(1:i-1,:);
  [f,v,n]=comprime_FVN(f,v,n,false);
  [nv,a]=size(v); [nf,a]=size(f);
  s =['Vertices = ',num2str(nv),'; Facets = ',num2str(nf),';'];
  disp(s);
end
