function bh=cnm_snm_2bh(nmin,cnm,snm)
% BH=CNM_SNM_2BH(NMIN,CNM,SNM)
% transforms spherical harmonic coefficients cnm, snm into a vector of coefficients bh
% nmin..minimum nonzero degree/order (1 or 2)
% Vector bh has the following ordering (for nmin=2): 
%     C20, C21, S21, C22, S22, C30, C31, S31, C32, S32, C33, S33, C40, C41, S41, etc.
%
% See also bh2_cnm_snm

% Ales Bezdek, 06/2011
% added nmin

nmax=length(cnm)-1;
Nsp=nmax^2+2*nmax-3*(nmin-1); %pocet SC
bh=zeros(Nsp,1);

j=1;
for n=nmin:nmax
   n1=n+1;
   for m=0:n
      m1=m+1;
      bh(j)=cnm(n1,m1);
%      fprintf('Cnm: n=%d  m=%d -> j=%d\n',n,m,j);
      j=j+1;
      if m~=0
         bh(j)=snm(n1,m1);
%          fprintf('Snm: n=%d  m=%d -> j=%d\n',n,m,j);
         j=j+1;
      end
   end
end
