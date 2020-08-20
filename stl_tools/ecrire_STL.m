function status=ecrire_STL(filename,f,v,n,debug)
% =========================================================
% Écriture d'un fichier STL
% =========================================================
  solid_on  = 'solid CATIA STL';
  solid_off = 'endsolid CATIA STL';
  facet_on  = '  facet normal';
  facet_off = '  endfacet';
  loop_on   = '    outer loop';
  loop_off  = '    endloop';
  vertex_on = '      vertex';
  
  status=false;
  %disp('Fonction: ecrire_STL() Version 1.0');
  fid=fopen(filename,'wt');
  fprintf('Writing %s...\n', filename);
  [nf,nv,nn,valide]=valide_FVN(f,v,n,debug);
  if valide && (fid~=-1)
    fprintf(fid,'%s\n',solid_on);     
    for i=1:nf         % Pour chaque facet
      fprintf(fid,'%s %-14.6e %-14.6e %-14.6e\n',facet_on,n(i,1),n(i,2),n(i,3));
      fprintf(fid,'%s\n',loop_on);   
      p=v(f(i,1),:);   % Premier vertex de la facet i
      fprintf(fid,'%s %-14.6e %-14.6e %-14.6e\n',vertex_on,p(1),p(2),p(3));
      p=v(f(i,2),:);   % Second vertex de la facet i
      fprintf(fid,'%s %-14.6e %-14.6e %-14.6e\n',vertex_on,p(1),p(2),p(3));
      p=v(f(i,3),:);   % Troisième vertex de la facet i
      fprintf(fid,'%s %-14.6e %-14.6e %-14.6e\n',vertex_on,p(1),p(2),p(3));
      fprintf(fid,'%s\n',loop_off);     
      fprintf(fid,'%s\n',facet_off);   
    end
    fprintf(fid,'%s\n',solid_off);
    status=true;
  else
    if debug
      disp('Erreur: FVN non valide ou ne peut ouvrir le fichier.');
      nv=0; nf=0;
    end
  end
  fclose(fid);
  s =['Vertices = ',num2str(nv),'; Facets = ',num2str(nf),';'];
  disp(s);
end
