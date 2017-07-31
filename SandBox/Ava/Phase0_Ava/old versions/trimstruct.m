function r = trimstruct(s)
  if isstruct(s)
    r = structfun(@trimstruct, s, 'Uniform', 0);
  else
    r = s(1:4);
  end
end