function [f2,v2,n2]=comprime_FVN(f1,v1,n1,debug)
% =========================================================
% Compression des matrices FVN (facets, vertices, normales)
% en éliminant les vertex identiques
% =========================================================
  %disp('Fonction: comprime_FVN() Version 1.0');
  [nf1,nv1,nn1,valide]=valide_FVN(f1,v1,n1,debug);
  if valide
    %s =['Début: Vertices = ',num2str(nv1),'; Facets = ',num2str(nf1),';'];
    %disp(s);
    f2=f1; n2=n1;      % Copie des facets et normales
    v2(1,:)=v1(1,:);   % Copie du 1er vertex
    nv2=1;
    for i=2:nv1        % Du vertex 2 à nv1 dans v1
      j=1;             % Cherche s'il existe déjà dans v2 ?
      while (v2(j,1)~=v1(i,1) || v2(j,2)~=v1(i,2) || v2(j,3)~=v1(i,3)) && j<nv2
        j=j+1;
      end
      if j==nv2 && (v2(j,1)~=v1(i,1) || v2(j,2)~=v1(i,2) || v2(j,3)~=v1(i,3))
        % Alors on ajoute le vertex i dans v2 à la fin
        if debug
          s=['Adding vertex ',num2str(i),';'];
          disp(s);
        end
        nv2=nv2+1; j=nv2;
        v2(nv2,:)=v1(i,:);
      end
      % Puis on remplace les numéros de vertex i par j
      f2=remplace_vertex(f2,i,j,debug);
    end
    [nf2,nv2,nn2,valide]=valide_FVN(f2,v2,n2,debug);   
    %s =['Fin  : Vertices = ',num2str(nv2),'; Facets = ',num2str(nf2),';'];
    %disp(s);
  end   
end
