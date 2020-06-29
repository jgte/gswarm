function [cnm,snm,ecnm,esnm]=bh2_cnm_snm(nmin,nmax,bh,diag_cov_mtx)
% [CNM,SNM,ECNM,ESNM]=BH2_CNM_SNM(NMIN,NMAX,BH,DIAG_COV_MTX)
% transforms the vector of coefficients bh and the diagonal of the covariance matrix cov_mtx
% into spherical harmonic coefficients cnm, snm and their errors ecnm, esnm
% nmin..minimum nonzero degree/order (1 or 2)
% nmax..maximum degree/order
% Vector bh has the following ordering (for nmin=2): 
%     C20, C21, S21, C22, S22, C30, C31, S31, C32, S32, C33, S33, C40, C41, S41, etc.
%
% See also cnm_snm_2bh

% Ales Bezdek, 06/2011
% update for nmin, 23/2/12

cnm=zeros(nmax+1,nmax+1); snm=cnm; ecnm=cnm; esnm=cnm;

j=1;
for n=nmin:nmax
   n1=n+1;
   for m=0:n
      m1=m+1;
      cnm(n1,m1)=bh(j);
      if nargin>3
         ecnm(n1,m1)=sqrt(diag_cov_mtx(j));
      end
      j=j+1;
      if m~=0
         snm(n1,m1)=bh(j);
         if nargin>3
            esnm(n1,m1)=sqrt(diag_cov_mtx(j));
         end
         j=j+1;
      end
   end
end
