function vecteur = lireXYZ(fid,masque,debug)
% ==================================================
% Lecture d'une ligne selon un masque et vecteur
% Input: fid     Identificateur de fichier ouvert
%        masque  Chaine de caract�res clef
%        debug   (true/false) Affichage d�taill�
% Output: vecteur coordonn�es X, Y et Z (vecteur ligne)
%         vecteur z�ro s'il y a une erreur
% ==================================================
  ligne=fgetl(fid);        % Lecture d'une ligne dans le fichier
  [n,m]=size(ligne);
  [o,n]=size(masque);      % Nombre de caract�re dans le masque
  ligne1=ligne(1:n);       % Partie 1 doit �tre identique au masque
  ligne2=ligne(n+1:m);     % Partie 2 contient X Y Z
  if strcmp(ligne1,masque)
	s=[masque,' -> OK'];
    vecteur=str2num(ligne2);
  else
    s=[masque,' -> Not OK'];  
    vecteur=[0, 0, 0];     % Un vecteur z�ro indique une erreur
  end
  if debug
    disp(s);
  end
end
