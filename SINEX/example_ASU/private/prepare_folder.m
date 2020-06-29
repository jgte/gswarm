function prepare_folder(adr,varargin)
%PREPARE_FOLDER(ADR)
% creates the folder ADR if it does not exist already
%
% PREPARE_FOLDER(ADR,'delete')
% deletes files contained in ADR, if such files exist

% 11/2014, bezdek@asu.cas.cz

%% Parsing optional arguments
i=1;
while i<=length(varargin),
   switch lower(varargin{i})
      case 'delete'
         if exist(adr,'file')
%          delete([ adr '/*.*']);
         system(sprintf('rm -rf %s',adr));
         end
   end;
   i=i+2;
end;
%%
if ~exist(adr,'file')
   mkdir(adr);
end

