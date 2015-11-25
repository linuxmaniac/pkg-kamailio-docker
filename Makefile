DISTS:=sid stretch jessie wheezy squeeze precise trusty

all:
	for i in $(DISTS) ; do \
		./create_dockerfile.sh $$i; \
	done

clean:
	rm -rf $(DISTS)
