open problemas;
for i=1:25
filename = ['2reverse_freitas_',num2str(i),'.txt'];
fid = fopen(filename,'w');
fprintf(fid, 'I %d\n', problemas{i}.n_i);
fprintf(fid, 'J %d\n', problemas{i}.n_j);
fprintf(fid, 'Pmax %d\n', problemas{i}.p_max);
fprintf(fid, 'Pmin %d\n', problemas{i}.p_min);
fprintf(fid, 'K %d\n', problemas{i}.n_k);
fprintf(fid, 'Qmax %d\n', problemas{i}.q_max);
fprintf(fid, 'Pmin %d\n', problemas{i}.p_min);
fprintf(fid, 'Locations i\n');
for j=1:problemas{i}.n_i
fprintf(fid, '%f %f\n', problemas{i}.pontos_i(j,:));
end
fprintf(fid, 'Locations j\n');
for j=1:problemas{i}.n_j
fprintf(fid, '%f %f\n', problemas{i}.pontos_j(j,:));
end
fprintf(fid, 'Locations k\n');
for j=1:problemas{i}.n_k
fprintf(fid, '%f %f\n', problemas{i}.pontos_k(j,:));
end
fprintf(fid, 'F\n');
for j=1:problemas{i}.n_j
fprintf(fid, '%f ', problemas{i}.f(j));
end
fprintf(fid, '\n');
fprintf(fid, 'G\n');
for j=1:problemas{i}.n_k
fprintf(fid, '%f ', problemas{i}.g(j));
end
fprintf(fid, '\n');
fprintf(fid, 'a\n');
for j=1:problemas{i}.n_i
fprintf(fid, '%f ', problemas{i}.a(j));
end
fprintf(fid, '\n');
fprintf(fid, 'B\n');
for j=1:problemas{i}.n_j
fprintf(fid, '%f ', problemas{i}.b(j));
end
fprintf(fid, '\n');
fprintf(fid, 'D\n');
for j=1:problemas{i}.n_k
fprintf(fid, '%f ', problemas{i}.d(j));
end
fprintf(fid, '\n');
for j1=1:problemas{i}.n_k
fprintf(fid, 'C, k=%d \n', j1);
for j2=1:problemas{i}.n_i
for j3=1:problemas{i}.n_j+1
fprintf(fid, '%f ', problemas{i}.c(j2,j3,j1));
end
fprintf(fid, '\n');
end
end
fclose(fid);
end