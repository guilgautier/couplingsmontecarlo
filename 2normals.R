rm(list = ls())
source("commongrounds.R")
library(doParallel)
library(doRNG)
registerDoParallel(cores = 10)

mu1 <- c(0,0)
mu2 <- c(3,3)
Sigma1 <- matrix(c(1,0,0,1), nrow = 2)
Sigma2 <- matrix(c(2,0.25,0.25,.5), nrow = 2)

cholSigma1 <- chol(Sigma1)
cholSigma2 <- chol(Sigma2)
invcholSigma1 <- chol(solve(Sigma1))
invcholSigma2 <- chol(solve(Sigma2))

scalingmatrix <- invcholSigma1 %*% t(chol(cholSigma1 %*% Sigma2 %*% cholSigma1)) %*% invcholSigma1
otmap <- function(vec){
  return(mu2 + scalingmatrix %*% (vec - mu1))
}

nsamples <- 1e4
xs <- mvtnorm::rmvnorm(nsamples, mu1, Sigma1)
zs <- t(apply(xs, 1, otmap))
df <- data.frame(x = xs)

ghex <- ggplot(df, aes(x = x.1, y = x.2)) + geom_hex(fill = colors[1], alpha = 0.75) +
  geom_hex(data = data.frame(zs), aes(x = X1, y = X2), fill = colors[2], alpha = 0.75)
gex <- ghex + ylim(-5,7) + xlim(-5, 10)
ghex
# ggsave(filename = "2dnormalshex.pdf", plot = ghex, height = 5, width = 5)

xseq <- seq(from = -4, to = 4, length.out = 15)
xs <- expand.grid(xseq, xseq)
zs <- t(apply(xs, 1, otmap))

got <- ggplot(data.frame(x = xs[,1], xend = zs[,1], y = xs[,2], yend = zs[,2]),
              aes(x = x, xend = xend, y = y, yend = yend)) +
  geom_segment(alpha = 0.5, arrow = arrow(length = unit(.5, "cm"))) 
got <- got + ylim(-5,7) + xlim(-5, 10)
got
# ggsave(filename = "2dnormalsOTmap.pdf", plot = got, height = 5, width = 5)

