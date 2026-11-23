r_dir = dirname(sys.frame(1)$ofile)
for (f in setdiff(list.files(r_dir, pattern = "\\.R$", full.names = TRUE),
                  file.path(r_dir, "load.R"))) {
  source(f)
}