% m-file: sinex_asu_01c
% 01c: added block SOLUTION/STATISTICS, and APPRIORI all equal to zeros, because our system is linear, not linearized
% 01b: names for J/B
% aim: to export ASU gravity field parameters & normal equations to the sinex format
% https://jgte.github.io/gswarm/SINEX/
% 3/2018, Ales Bezdek, bezdek@asu.cas.cz
clear

version_pg=1;

% Input folder:
% adr='C:\ales\matlab\grav_field_estimation\sinex\komb_SW_g3f_NK03_NormMtx\'; %n40..28sek one file
adr='/home/ales/vysledky/tvg/dt05_n40_ns120/komb_SW_g3f_NK03_NormMtx/';
adr='/home/ales/vysledky/tvg/dt05_n40_ns120/komb_SW_J_NK03_NormMtx/';
adr='/home/ales/vysledky/tvg/dt05_n40_ns120/komb_SW_B_NK03_NormMtx/';

% test: uncomment
adr='./komb_SW_NK03_NormMtx_nmax20/'; %n20..2sek one file
% adr='./komb_SW_NK03_NormMtx_nmax40/'; 

adr_shc=[ adr 'sc_mat/' ];
adr_nm=[ adr 'nm_mat/' ];

adr_new_files=[ adr 'sinex/' ];
prepare_folder(adr_new_files);

if strfind(adr,'_B_')
   jm_orbit='AIUB';
elseif strfind(adr,'_J_')
   jm_orbit='TUD';
else
   jm_orbit='IFG';
end

seznam_soub=dir(adr_shc);
soub={seznam_soub.name};   %vytvori bunku se jmeny souboru
for i=1:length(soub)
   n2c=strfind(char(soub{i}),'.mat');
   if ~isempty(n2c); break; end
end
n2c=i-1;
n2=length(soub)-n2c;
fprintf('\nNumber of data files to process: %d\n',n2);

tic
for i1=1:n2
   i1a=i1+n2c;
   jm=soub{i1a};
   fprintf('Processing %d of %d files\n',i1,n2);
   fprintf('   input file: %s\n',jm);
   clear cnm snm ecnm esnm header epoch_yr intv_yr nmin nmax norm_mtx norm_mtx4
   
   load([ adr_shc jm]);
   jm_nm=[jm(1:end-7) '_norm_mtx.mat'];
   load([ adr_nm jm_nm]);
   
   % load('gpest_10_SC14dt30_g4fa_2015_0101_-1cm_n20_c_02d_norm_mtx.mat','norm_mtx4','nmin','nmax');
   % load('gpest_10_SC14dt30_g4fa_2015_0101_n20_c_02d_sp_k1.mat','cnm','snm','ecnm','esnm','header','epoch_yr','intv_yr');
   %
   % load('gpest_10_sim230km010dt30_2015_0509_n10_c_01d_sp_k0.mat','norm_mtx4','nmin','nmax');
   % load('gpest_10_sim230km010dt30_2015_0509_1cm_n10_c_01d_norm_mtx.mat','cnm','snm','ecnm','esnm','header','epoch_yr','intv_yr');
   
   % header =   struct with fields:
   %                  modelname: 'gpest_10_sim230km010dt30_2015_0509_n10_c_01d_30s_acc011_aeh011_blk3.000000e-01'
   %     earth_gravity_constant: 3.986e+14
   %                     radius: 6.3781e+06
   %                 max_degree: 10
   %                 min_degree: 2
   %                tide_system: 'tide_free'
   
   bh1=cnm_snm_2bh(nmin,cnm,snm);
   ebh1=cnm_snm_2bh(nmin,ecnm,esnm);
   n_shc=size(bh1,1);
   n_obs=3*sum(N_fit_komb(:)); %three times for each LRF shc for each entering satellite
   n_sat_komb=size(N_fit_komb,1); % number of satellites in ASU comb solution
   ssr=0;
   for j=1:n_sat_komb
      % vPv=MSE*(N_fit-Nsp)
      % ssr_sa=sum(vPv)
      ssr1=mse_komb(j,:)*(N_fit_komb(j)-n_shc);
      ssr=ssr+sum(ssr1(:));
   end
   fprintf('   number of observations     % d\n',n_obs);
   fprintf('   number of unknowns         % d\n',n_shc);
   fprintf('   weighted square sum of o-c % d\n',ssr);
   
   % vector of right-hand sides
   if exist('norm_mtx4','var')
      norm_mtx=norm_mtx4;
   end
   rhs=norm_mtx*bh1;
   
   % epochs
   [doy1,yr1]=jd2doy(yr2jd(epoch_yr));
   [yr,mm1,dd1]=jd2cal(yr2jd(epoch_yr));
   fprintf('   epoch: %s\n',datestr(doy2dtn(yr1,doy1)));
   [doy2,yr2]=jd2doy(yr2jd(intv_yr(1)));
   fprintf('   start: %s\n',datestr(doy2dtn(yr2,doy2)));
   [doy3,yr3]=jd2doy(yr2jd(intv_yr(2)));
   fprintf('     end: %s\n',datestr(doy2dtn(yr3,doy3)));
   
   %%
   modelname1=header.modelname;
   nmax1=header.max_degree;
   sats='Swarm'; sat='Swarm A/B/C (combined)';
   modelname=sprintf('ASU-%s-%d-%02d-nmax%02d-orbits-%s',sats,yr1,mm1,nmax1,jm_orbit);
   % s='Orbits kindly provided by: Institute of Geodesy, TU Graz, Austria (ftp://ftp.tugraz.at/outgoing/ITSG/tvgogo/orbits/)\n';
   %%
   % GSWARM_NE_SABC_IFG_2017-12_04_IFG.snx
   % GSWARM_NE_SABC_IFG_2013-11_02_AIUB.snx
   soub1=sprintf('GSWARM_NE_SABC_ASU_%d-%02d_%02d_%s.snx',yr1,mm1,version_pg,jm_orbit);
   % fprintf('   modelname: %s\n',modelname);
   fprintf('   Exporting: %s\n',soub1);
   
   fid=fopen(soub1,'w');
   
   %=SNX 2.02 IFG 18:071:37898 IFG 17:335:00000 18:001:00000 C 03717 2            2
   % ifg:      parameter.constraintCode = "2"; // unconstrained
   [doy4,yr4]=dtn2doy(now);
   fprintf(fid,'%%=SNX 2.02 ASU %02d:%03d:%05.0f ASU %02d:%03d:%05.0f %02d:%03d:%05.0f P %05d 2            2\n',...
      yr4-2000,floor(doy4),(doy4-floor(doy4))*86400,...
      yr2-2000,floor(doy2),(doy2-floor(doy2))*86400,...
      yr3-2000,floor(doy3),(doy3-floor(doy3))*86400,n_shc);
   
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   fprintf(fid,'+FILE/REFERENCE\n');
   fprintf(fid,'*INFO_TYPE_________ INFO________________________________________________________\n');
   fprintf(fid,' DESCRIPTION        Swarm monthly gravity field\n');
   fprintf(fid,' CONTACT            ales.bezdek@asu.cas.cz\n');
   fprintf(fid,' SOFTWARE           ASU Decorrelated Acceleration Approach (gpest_10)\n');
   fprintf(fid,' INPUT              Swarm kinematic orbits\n');
   fprintf(fid,'*Internal info:\n');
   %    modelname1=[modelname1 modelname1 modelname1 modelname1];
   if length(modelname1)>77
      if length(modelname1)<155
         fprintf(fid,'* %s\n',modelname1(1:77));
         fprintf(fid,'* %s\n',modelname1(78:end));
      else
         fprintf(fid,'* %s\n',modelname1(1:77));
         fprintf(fid,'* %s\n',modelname1(78:154));
         fprintf(fid,'* %s\n',modelname1(155:end));
      end
   else
      fprintf(fid,'* %s \n',modelname1(1:end));
   end
   fprintf(fid,'* pg: sinex_asu_01c, %s\n',datestr(now));
   fprintf(fid,'-FILE/REFERENCE\n');
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   fprintf(fid,'+FILE/COMMENT\n');
   %fprintf(fid,' modelname              EGSIEM_AIUB_RL01\n');
   % fprintf(fid,' earth_gravity_constant 3.9860044150e+14\n');
   % fprintf(fid,' radius                 6.3781363000e+06\n');
   % fprintf(fid,' max_degree             90\n');
   % fprintf(fid,' tide_system            tide_free\n');
   fprintf(fid,' modelname              %s\n',modelname);
   fprintf(fid,' earth_gravity_constant %.10g\n',header.earth_gravity_constant);
   fprintf(fid,' radius                 %.10g\n',header.radius);
   fprintf(fid,' max_degree             %g\n',header.max_degree);
   fprintf(fid,' norm                   fully_normalized\n');
   fprintf(fid,' tide_system            %s\n',header.tide_system);
   fprintf(fid,'-FILE/COMMENT\n');
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   
   fprintf(fid,'+SOLUTION/STATISTICS\n');
   fprintf(fid,'*____STATISTICAL_PARAMETER_____ _______VALUE(S)_______\n');
   % fprintf(fid,' NUMBER OF DEGREES OF FREEDOM                   110953\n');
   % fprintf(fid,' NUMBER OF OBSERVATIONS                         111390\n');
   % fprintf(fid,' NUMBER OF UNKNOWNS                                437\n');
   % fprintf(fid,' WEIGHTED SQUARE SUM OF O-C     111757.174401915995986\n');
   fprintf(fid,' NUMBER OF OBSERVATIONS         %22.15g\n',n_obs);   
   fprintf(fid,' NUMBER OF UNKNOWNS             %22.15g\n',n_shc);
   fprintf(fid,' WEIGHTED SQUARE SUM OF O-C     %22.15g\n',ssr);
   fprintf(fid,'-SOLUTION/STATISTICS\n');
   fprintf(fid,'*-------------------------------------------------------------------------------\n');

   fprintf(fid,'+SOLUTION/ESTIMATE\n');
   fprintf(fid,'*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ___ESTIMATED_VALUE___ __STD_DEV__\n');
   
   % fprintf(fid,'     1 CN        2 --    0 13:332:00000 ---- 2  5.30968096716456e-10 1.53293e-10\n');
   % fprintf(fid,'     2 CN        2 --    1 13:332:00000 ---- 2  2.21624032571824e-10 1.53551e-10\n');
   % fprintf(fid,'     3 SN        2 --    1 13:332:00000 ---- 2 -1.76103579339908e-10 1.81785e-10\n');
   % fprintf(fid,'   436 CN       20 --   20 13:332:00000 ---- 2 -8.22204335556664e-12 6.88808e-11\n');
   % fprintf(fid,'   437 SN       20 --   20 13:332:00000 ---- 2 -9.93059329298290e-12 6.88701e-11\n');
   
   j=1;
   for n=nmin:nmax
      n1=n+1;
      for m=0:n
         m1=m+1;
         %          cnm(n1,m1)=bh(j);
         fprintf(fid,' %5d CN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e %10.5e\n',...
            j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,cnm(n1,m1),ecnm(n1,m1));
         
         j=j+1;
         if m~=0
            %             snm(n1,m1)=bh(j);
            fprintf(fid,' %5d SN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e %10.5e\n',...
               j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,snm(n1,m1),esnm(n1,m1));
            j=j+1;
         end
      end
   end
   
   fprintf(fid,'-SOLUTION/ESTIMATE\n');
   
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   fprintf(fid,'+SOLUTION/APRIORI\n');
   fprintf(fid,'*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ____APRIORI_VALUE____ __STD_DEV__\n');
   % fprintf(fid,'     1 CN        2 --    0 13:332:00000 ---- 2 -4.84169455272500e-04 0.00000e+00\n');
   % fprintf(fid,'     2 CN        2 --    1 13:332:00000 ---- 2 -3.38789250435300e-10 0.00000e+00\n');
   % fprintf(fid,'     3 SN        2 --    1 13:332:00000 ---- 2  1.45032726836400e-09 0.00000e+00\n');
   % fprintf(fid,'     4 CN        2 --    2 13:332:00000 ---- 2  2.43935719686800e-06 0.00000e+00\n');
   % fprintf(fid,'     5 SN        2 --    2 13:332:00000 ---- 2 -1.40030349070500e-06 0.00000e+00\n');
   % fprintf(fid,'     6 CN        3 --    0 13:332:00000 ---- 2  9.57193698546200e-07 0.00000e+00\n');
   % fprintf(fid,'     7 CN        3 --    1 13:332:00000 ---- 2  2.03045857676400e-06 0.00000e+00\n');
   % fprintf(fid,'...\n');
   % fprintf(fid,'   436 CN       20 --   20 13:332:00000 ---- 2  3.73346769324500e-09 0.00000e+00\n');
   % fprintf(fid,'   437 SN       20 --   20 13:332:00000 ---- 2 -1.26961701956600e-08 0.00000e+00\n');
   
   j=1;
   for n=nmin:nmax
      n1=n+1;
      for m=0:n
         m1=m+1;
         %          cnm(n1,m1)=bh(j);
         fprintf(fid,' %5d CN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e %10.5e\n',...
            j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,0,0);
         
         j=j+1;
         if m~=0
            %             snm(n1,m1)=bh(j);
            fprintf(fid,' %5d SN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e %10.5e\n',...
               j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,0,0);
            j=j+1;
         end
      end
   end
   
   fprintf(fid,'-SOLUTION/APRIORI\n');
   
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   fprintf(fid,'+SOLUTION/NORMAL_EQUATION_VECTOR\n');
   fprintf(fid,'*INDEX _TYPE_ CODE PT SOLN _REF_EPOCH__ UNIT S ___RIGHT_HAND_SIDE___\n');
   % fprintf(fid,'     1 CN        2 --    0 13:332:00000 ---- 2  1.94456779522556e+10\n');
   % fprintf(fid,'     2 CN        2 --    1 13:332:00000 ---- 2  4.02733100679237e+09\n');
   % fprintf(fid,'     3 SN        2 --    1 13:332:00000 ---- 2 -5.12435134925468e+09\n');
   
   j=1;
   for n=nmin:nmax
      n1=n+1;
      for m=0:n
         m1=m+1;
         %          cnm(n1,m1)=bh(j);
         fprintf(fid,' %5d CN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e\n',...
            j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,rhs(j));
         
         j=j+1;
         if m~=0
            %             snm(n1,m1)=bh(j);
            fprintf(fid,' %5d SN     %4d -- %4d %02d:%03d:%05.0f ---- 2 % 20.14e\n',...
               j,n,m,yr1-2000,floor(doy1),(doy1-floor(doy1))*86400,rhs(j));
            j=j+1;
         end
      end
   end
   
   fprintf(fid,'-SOLUTION/NORMAL_EQUATION_VECTOR\n');
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   
   fprintf(fid,'+SOLUTION/NORMAL_EQUATION_MATRIX U\n');
   fprintf(fid,'*PARA1 PARA2 _______PARA2+0_______ _______PARA2+1_______ _______PARA2+2_______\n');
   % fprintf(fid,'     1     1  6.24472418779328e+19  4.94812478934832e+17 -1.17308420279783e+18\n');
   % fprintf(fid,'     1     4 -7.55282104282444e+18 -5.04276460252251e+18  1.44096525090260e+19\n');
   % fprintf(fid,'     1     7 -1.61183969785064e+18 -8.21686706339053e+18 -2.25352913501924e+18\n');
   % fprintf(fid,'     1    10 -1.42118433846006e+18  9.06035699357613e+16  4.50970914593250e+17\n');
   % fprintf(fid,'     1    13  3.53465716416835e+19 -2.26674064900587e+18 -4.26611486776763e+18\n');
   % fprintf(fid,'     1    16  3.84297724286029e+18  5.62677605992882e+18 -3.90918637208197e+18\n');
   %      1   433  8.76197447917639e+17 -2.31765546649340e+17  2.23428178572787e+18
   %      1   436  3.74742332984110e+17 -1.59125055612271e+17
   %      2     2  5.45920514403985e+19  4.86825401044619e+18 -4.99175053121066e+17
   % fprintf(fid,'   434   434  4.07135957203586e+20 -1.17456215162332e+19 -8.81140238125939e+17\n');
   % fprintf(fid,'   434   437 -1.49247208588356e+19\n');
   % fprintf(fid,'   435   435  4.15062118715528e+20  1.17291576608708e+19  3.48630775598820e+18\n');
   % fprintf(fid,'   436   436  3.37067281060801e+20  5.22222193065282e+18\n');
   % fprintf(fid,'   437   437  3.22282674265033e+20\n');
   
   for j=1:n_shc
      for k=j:3:n_shc
         fprintf(fid,' %5d %5d',j,k);
         for m=0:2
            m1=k+m;
            if m1>n_shc; break; end
            fprintf(fid,' % 20.14e',norm_mtx(j,m1));
         end
         fprintf(fid,'\n');
      end
   end
   
   fprintf(fid,'-SOLUTION/NORMAL_EQUATION_MATRIX U\n');
   fprintf(fid,'*-------------------------------------------------------------------------------\n');
   fprintf(fid,'%%ENDSNX\n');
   
   fclose(fid);
   if strcmp(adr,'./komb_SW_NK03_NormMtx_nmax20/'); return; end %test
   gzip(soub1); delete(soub1)
   toc
end
movefile('*.snx*',adr_new_files);

if isunix; quit; end   %musi tady byt pro spousteni pres nohup
