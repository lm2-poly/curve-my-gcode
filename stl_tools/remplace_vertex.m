function f2=remplace_vertex(f1,old_vertex,new_vertex,debug)
% ========================================================
% Remplace dans f1 les numéros de vertex i par j
% ========================================================
  f2=f1;  
  [n,m]=size(f1);
  for i=1:n
    for j=1:m
      if f2(i,j)==old_vertex
        f2(i,j)=new_vertex;
      end  
    end
  end    
  if debug
    s=['Replace vertex ',num2str(old_vertex),' by ',num2str(new_vertex),';'];
    disp(s);
  end
end
