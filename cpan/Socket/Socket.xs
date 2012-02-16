#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <stddef.h>

#ifdef I_SYS_TYPES
#  include <sys/types.h>
#endif
#if !defined(ultrix) /* Avoid double definition. */
#   include <sys/socket.h>
#endif
#if defined(USE_SOCKS) && defined(I_SOCKS)
#   include <socks.h>
#endif
#ifdef MPE
#  define PF_INET AF_INET
#  define PF_UNIX AF_UNIX
#  define SOCK_RAW 3
#endif
#ifdef I_SYS_UN
#  include <sys/un.h>
#endif
/* XXX Configure test for <netinet/in_systm.h needed XXX */
#if defined(NeXT) || defined(__NeXT__)
#  include <netinet/in_systm.h>
#endif
#if defined(__sgi) && !defined(AF_LINK) && defined(PF_LINK) && PF_LINK == AF_LNK
#  undef PF_LINK
#endif
#if defined(I_NETINET_IN) || defined(__ultrix__)
#  include <netinet/in.h>
#endif
#ifdef I_NETDB
#  if !defined(ultrix)	/* Avoid double definition. */
#   include <netdb.h>
#  endif
#endif
#ifdef I_ARPA_INET
#  include <arpa/inet.h>
#endif
#ifdef I_NETINET_TCP
#  include <netinet/tcp.h>
#endif

#ifdef NETWARE
NETDB_DEFINE_CONTEXT
NETINET_DEFINE_CONTEXT
#endif

#ifdef I_SYSUIO
# include <sys/uio.h>
#endif

#ifndef AF_NBS
# undef PF_NBS
#endif

#ifndef AF_X25
# undef PF_X25
#endif

#ifndef INADDR_NONE
# define INADDR_NONE	0xffffffff
#endif /* INADDR_NONE */
#ifndef INADDR_BROADCAST
# define INADDR_BROADCAST	0xffffffff
#endif /* INADDR_BROADCAST */
#ifndef INADDR_LOOPBACK
# define INADDR_LOOPBACK	 0x7F000001
#endif /* INADDR_LOOPBACK */

#ifndef C_ARRAY_LENGTH
#define C_ARRAY_LENGTH(arr) (sizeof(arr) / sizeof(*(arr)))
#endif /* !C_ARRAY_LENGTH */

#ifndef PERL_UNUSED_VAR
# define PERL_UNUSED_VAR(x) ((void)x)
#endif /* !PERL_UNUSED_VAR */

#ifndef PERL_UNUSED_ARG
# define PERL_UNUSED_ARG(x) PERL_UNUSED_VAR(x)
#endif /* !PERL_UNUSED_ARG */

#ifndef Newx
# define Newx(v,n,t) New(0,v,n,t)
#endif /* !Newx */

#ifndef croak_sv
# define croak_sv(sv)	croak(SvPV_nolen(sv))
#endif

#ifndef hv_stores
# define hv_stores(hv, keystr, val) \
	hv_store(hv, ""keystr"", sizeof(keystr)-1, val, 0)
#endif /* !hv_stores */

#ifndef newSVpvn_flags
# define newSVpvn_flags(s,len,flags) my_newSVpvn_flags(aTHX_ s,len,flags)
static SV *my_newSVpvn_flags(pTHX_ const char *s, STRLEN len, U32 flags)
{
  SV *sv = newSVpvn(s, len);
  SvFLAGS(sv) |= (flags & SVf_UTF8);
  return (flags & SVs_TEMP) ? sv_2mortal(sv) : sv;
}
#endif /* !newSVpvn_flags */

#ifndef SvRV_set
# define SvRV_set(sv, val) (SvRV(sv) = (val))
#endif /* !SvRV_set */

#ifndef SvPV_nomg
# define SvPV_nomg SvPV
#endif /* !SvPV_nomg */

#ifndef HEK_FLAGS
# define HEK_FLAGS(hek) 0
# define HVhek_UTF8 1
#endif /* !HEK_FLAGS */

#ifndef hv_common
/* These magic numbers are arbitrarily chosen (copied from perl core in fact)
 * and only have to match between this definition and the code that uses them
 */
# define HV_FETCH_ISSTORE 0x04
# define HV_FETCH_LVALUE  0x10
# define hv_common(hv, keysv, key, klen, flags, act, val, hash) \
	my_hv_common(aTHX_ hv, keysv, key, klen, flags, act, val, hash)
static void *my_hv_common(pTHX_ HV *hv, SV *keysv, const char *key, STRLEN klen,
	int flags, int act, SV *val, U32 hash)
{
	/*
	 * This only handles the usage actually made by the code
	 * generated by ExtUtils::Constant.  EU:C really ought to arrange
	 * portability of its generated code itself.
	 */
	if (!keysv) {
		keysv = sv_2mortal(newSVpvn(key, klen));
		if (flags & HVhek_UTF8)
			SvUTF8_on(keysv);
	}
	if (act == HV_FETCH_LVALUE) {
		return (void*)hv_fetch_ent(hv, keysv, 1, hash);
	} else if (act == HV_FETCH_ISSTORE) {
		return (void*)hv_store_ent(hv, keysv, val, hash);
	} else {
		croak("panic: my_hv_common: act=0x%x", act);
	}
}
#endif /* !hv_common */

#ifndef hv_common_key_len
# define hv_common_key_len(hv, key, kl, act, val, hash) \
	my_hv_common_key_len(aTHX_ hv, key, kl, act, val, hash)
static void *my_hv_common_key_len(pTHX_ HV *hv, const char *key, I32 kl,
	int act, SV *val, U32 hash)
{
	STRLEN klen;
	int flags;
	if (kl < 0) {
		klen = -kl;
		flags = HVhek_UTF8;
	} else {
		klen = kl;
		flags = 0;
	}
	return hv_common(hv, NULL, key, klen, flags, act, val, hash);
}
#endif /* !hv_common_key_len */

#ifndef mPUSHi
# define mPUSHi(i) sv_setiv_mg(PUSHs(sv_newmortal()), (IV)(i))
#endif /* !mPUSHi */
#ifndef mPUSHp
# define mPUSHp(p,l) sv_setpvn_mg(PUSHs(sv_newmortal()), (p), (l))
#endif /* !mPUSHp */

#ifndef CvCONST_on
# undef newCONSTSUB
# define newCONSTSUB(stash, name, val) my_newCONSTSUB(aTHX_ stash, name, val)
static CV *my_newCONSTSUB(pTHX_ HV *stash, char *name, SV *val)
{
	/*
	 * This has to satisfy code generated by ExtUtils::Constant.
	 * It depends on the 5.8+ layout of constant subs.  It has
	 * two calls to newCONSTSUB(): one for real constants, and one
	 * for undefined constants.  In the latter case, it turns the
	 * initially-generated constant subs into something else, and
	 * it needs the return value from newCONSTSUB() which Perl 5.6
	 * doesn't provide.
	 */
	GV *gv;
	CV *cv;
	Perl_newCONSTSUB(aTHX_ stash, name, val);
	ENTER;
	SAVESPTR(PL_curstash);
	PL_curstash = stash;
	gv = gv_fetchpv(name, 0, SVt_PVCV);
	cv = GvCV(gv);
	LEAVE;
	CvXSUBANY(cv).any_ptr = &PL_sv_undef;
	return cv;
}
# define CvCONST_off(cv) my_CvCONST_off(aTHX_ cv)
static void my_CvCONST_off(pTHX_ CV *cv)
{
	op_free(CvROOT(cv));
	CvROOT(cv) = NULL;
	CvSTART(cv) = NULL;
}
#endif /* !CvCONST_on */

#ifndef HAS_INET_ATON

/*
 * Check whether "cp" is a valid ascii representation
 * of an Internet address and convert to a binary address.
 * Returns 1 if the address is valid, 0 if not.
 * This replaces inet_addr, the return value from which
 * cannot distinguish between failure and a local broadcast address.
 */
static int
my_inet_aton(register const char *cp, struct in_addr *addr)
{
	dTHX;
	register U32 val;
	register int base;
	register char c;
	int nparts;
	const char *s;
	unsigned int parts[4];
	register unsigned int *pp = parts;

	if (!cp || !*cp)
		return 0;
	for (;;) {
		/*
		 * Collect number up to ".".
		 * Values are specified as for C:
		 * 0x=hex, 0=octal, other=decimal.
		 */
		val = 0; base = 10;
		if (*cp == '0') {
			if (*++cp == 'x' || *cp == 'X')
				base = 16, cp++;
			else
				base = 8;
		}
		while ((c = *cp) != '\0') {
			if (isDIGIT(c)) {
				val = (val * base) + (c - '0');
				cp++;
				continue;
			}
			if (base == 16 && (s=strchr(PL_hexdigit,c))) {
				val = (val << 4) +
					((s - PL_hexdigit) & 15);
				cp++;
				continue;
			}
			break;
		}
		if (*cp == '.') {
			/*
			 * Internet format:
			 *	a.b.c.d
			 *	a.b.c	(with c treated as 16-bits)
			 *	a.b	(with b treated as 24 bits)
			 */
			if (pp >= parts + 3 || val > 0xff)
				return 0;
			*pp++ = val, cp++;
		} else
			break;
	}
	/*
	 * Check for trailing characters.
	 */
	if (*cp && !isSPACE(*cp))
		return 0;
	/*
	 * Concoct the address according to
	 * the number of parts specified.
	 */
	nparts = pp - parts + 1;	/* force to an int for switch() */
	switch (nparts) {

	case 1:				/* a -- 32 bits */
		break;

	case 2:				/* a.b -- 8.24 bits */
		if (val > 0xffffff)
			return 0;
		val |= parts[0] << 24;
		break;

	case 3:				/* a.b.c -- 8.8.16 bits */
		if (val > 0xffff)
			return 0;
		val |= (parts[0] << 24) | (parts[1] << 16);
		break;

	case 4:				/* a.b.c.d -- 8.8.8.8 bits */
		if (val > 0xff)
			return 0;
		val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
		break;
	}
	addr->s_addr = htonl(val);
	return 1;
}

#undef inet_aton
#define inet_aton my_inet_aton

#endif /* ! HAS_INET_ATON */

/* These are not gni() constants; they're extensions for the perl API */
/* The definitions in Socket.pm and Socket.xs must match */
#define NIx_NOHOST   (1 << 0)
#define NIx_NOSERV   (1 << 1)


static int
not_here(const char *s)
{
    croak("Socket::%s not implemented on this architecture", s);
    return -1;
}

#define PERL_IN_ADDR_S_ADDR_SIZE 4

/*
* Bad assumptions possible here.
*
* Bad Assumption 1: struct in_addr has no other fields
* than the s_addr (which is the field we care about
* in here, really). However, we can be fed either 4-byte
* addresses (from pack("N", ...), or va.b.c.d, or ...),
* or full struct in_addrs (from e.g. pack_sockaddr_in()),
* which may or may not be 4 bytes in size.
*
* Bad Assumption 2: the s_addr field is a simple type
* (such as an int, u_int32_t).	It can be a bit field,
* in which case using & (address-of) on it or taking sizeof()
* wouldn't go over too well.  (Those are not attempted
* now but in case someone thinks to change the below code
* to use addr.s_addr instead of addr, you have been warned.)
*
* Bad Assumption 3: the s_addr is the first field in
* an in_addr, or that its bytes are the first bytes in
* an in_addr.
*
* These bad assumptions are wrong in UNICOS which has
* struct in_addr { struct { u_long  st_addr:32; } s_da };
* #define s_addr s_da.st_addr
* and u_long is 64 bits.
*
* --jhi */

#include "const-c.inc"

#ifdef HAS_GETADDRINFO
static SV *err_to_SV(pTHX_ int err)
{
	SV *ret = sv_newmortal();
	(void) SvUPGRADE(ret, SVt_PVNV);

	if(err) {
		const char *error = gai_strerror(err);
		sv_setpv(ret, error);
	}
	else {
		sv_setpv(ret, "");
	}

	SvIV_set(ret, err); SvIOK_on(ret);

	return ret;
}

static void xs_getaddrinfo(pTHX_ CV *cv)
{
	dXSARGS;

	SV   *host;
	SV   *service;
	SV   *hints;

	char *hostname = NULL;
	char *servicename = NULL;
	STRLEN len;
	struct addrinfo hints_s;
	struct addrinfo *res;
	struct addrinfo *res_iter;
	int err;
	int n_res;

	PERL_UNUSED_ARG(cv);
	if(items > 3)
		croak("Usage: Socket::getaddrinfo(host, service, hints)");

	SP -= items;

	if(items < 1)
		host = &PL_sv_undef;
	else
		host = ST(0);

	if(items < 2)
		service = &PL_sv_undef;
	else
		service = ST(1);

	if(items < 3)
		hints = NULL;
	else
		hints = ST(2);

	SvGETMAGIC(host);
	if(SvOK(host)) {
		hostname = SvPV_nomg(host, len);
		if (!len)
			hostname = NULL;
	}

	SvGETMAGIC(service);
	if(SvOK(service)) {
		servicename = SvPV_nomg(service, len);
		if (!len)
			servicename = NULL;
	}

	Zero(&hints_s, sizeof(hints_s), char);
	hints_s.ai_family = PF_UNSPEC;

	if(hints && SvOK(hints)) {
		HV *hintshash;
		SV **valp;

		if(!SvROK(hints) || SvTYPE(SvRV(hints)) != SVt_PVHV)
			croak("hints is not a HASH reference");

		hintshash = (HV*)SvRV(hints);

		if((valp = hv_fetch(hintshash, "flags", 5, 0)) != NULL)
			hints_s.ai_flags = SvIV(*valp);
		if((valp = hv_fetch(hintshash, "family", 6, 0)) != NULL)
			hints_s.ai_family = SvIV(*valp);
		if((valp = hv_fetch(hintshash, "socktype", 8, 0)) != NULL)
			hints_s.ai_socktype = SvIV(*valp);
		if((valp = hv_fetch(hintshash, "protocol", 8, 0)) != NULL)
			hints_s.ai_protocol = SvIV(*valp);
	}

	err = getaddrinfo(hostname, servicename, &hints_s, &res);

	XPUSHs(err_to_SV(aTHX_ err));

	if(err)
		XSRETURN(1);

	n_res = 0;
	for(res_iter = res; res_iter; res_iter = res_iter->ai_next) {
		HV *res_hv = newHV();

		(void)hv_stores(res_hv, "family",   newSViv(res_iter->ai_family));
		(void)hv_stores(res_hv, "socktype", newSViv(res_iter->ai_socktype));
		(void)hv_stores(res_hv, "protocol", newSViv(res_iter->ai_protocol));

		(void)hv_stores(res_hv, "addr",     newSVpvn((char*)res_iter->ai_addr, res_iter->ai_addrlen));

		if(res_iter->ai_canonname)
			(void)hv_stores(res_hv, "canonname", newSVpv(res_iter->ai_canonname, 0));
		else
			(void)hv_stores(res_hv, "canonname", newSV(0));

		XPUSHs(sv_2mortal(newRV_noinc((SV*)res_hv)));
		n_res++;
	}

	freeaddrinfo(res);

	XSRETURN(1 + n_res);
}
#endif

#ifdef HAS_GETNAMEINFO
static void xs_getnameinfo(pTHX_ CV *cv)
{
	dXSARGS;

	SV  *addr;
	int  flags;
	int  xflags;

	char host[1024];
	char serv[256];
	char *sa; /* we'll cast to struct sockaddr * when necessary */
	STRLEN addr_len;
	int err;

	int want_host, want_serv;

	PERL_UNUSED_ARG(cv);
	if(items < 1 || items > 3)
		croak("Usage: Socket::getnameinfo(addr, flags=0, xflags=0)");

	SP -= items;

	addr = ST(0);

	if(items < 2)
		flags = 0;
	else
		flags = SvIV(ST(1));

	if(items < 3)
		xflags = 0;
	else
		xflags = SvIV(ST(2));

	want_host = !(xflags & NIx_NOHOST);
	want_serv = !(xflags & NIx_NOSERV);

	if(!SvPOK(addr))
		croak("addr is not a string");

	addr_len = SvCUR(addr);

	/* We need to ensure the sockaddr is aligned, because a random SvPV might
	 * not be due to SvOOK */
	Newx(sa, addr_len, char);
	Copy(SvPV_nolen(addr), sa, addr_len, char);
#ifdef HAS_SOCKADDR_SA_LEN
	((struct sockaddr *)sa)->sa_len = addr_len;
#endif

	err = getnameinfo((struct sockaddr *)sa, addr_len,
			want_host ? host : NULL, want_host ? sizeof(host) : 0,
			want_serv ? serv : NULL, want_serv ? sizeof(serv) : 0,
			flags);

	Safefree(sa);

	XPUSHs(err_to_SV(aTHX_ err));

	if(err)
		XSRETURN(1);

	XPUSHs(want_host ? sv_2mortal(newSVpv(host, 0)) : &PL_sv_undef);
	XPUSHs(want_serv ? sv_2mortal(newSVpv(serv, 0)) : &PL_sv_undef);

	XSRETURN(3);
}
#endif

MODULE = Socket		PACKAGE = Socket

INCLUDE: const-xs.inc

BOOT:
#ifdef HAS_GETADDRINFO
	newXS("Socket::getaddrinfo", xs_getaddrinfo, __FILE__);
#endif
#ifdef HAS_GETNAMEINFO
	newXS("Socket::getnameinfo", xs_getnameinfo, __FILE__);
#endif

void
inet_aton(host)
	char *	host
	CODE:
	{
	struct in_addr ip_address;
	struct hostent * phe;

	if ((*host != '\0') && inet_aton(host, &ip_address)) {
		ST(0) = sv_2mortal(newSVpvn((char *)&ip_address, sizeof(ip_address)));
		XSRETURN(1);
	}

	phe = gethostbyname(host);
	if (phe && phe->h_addrtype == AF_INET && phe->h_length == 4) {
		ST(0) = sv_2mortal(newSVpvn((char *)phe->h_addr, phe->h_length));
		XSRETURN(1);
	}

	XSRETURN_UNDEF;
	}

void
inet_ntoa(ip_address_sv)
	SV *	ip_address_sv
	CODE:
	{
	STRLEN addrlen;
	struct in_addr addr;
	char * ip_address;
	if (DO_UTF8(ip_address_sv) && !sv_utf8_downgrade(ip_address_sv, 1))
		croak("Wide character in %s", "Socket::inet_ntoa");
	ip_address = SvPVbyte(ip_address_sv, addrlen);
	if (addrlen == sizeof(addr) || addrlen == 4)
		addr.s_addr =
		    (ip_address[0] & 0xFF) << 24 |
		    (ip_address[1] & 0xFF) << 16 |
		    (ip_address[2] & 0xFF) <<  8 |
		    (ip_address[3] & 0xFF);
	else
		croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		      "Socket::inet_ntoa", (UV)addrlen, (UV)sizeof(addr));
	/* We could use inet_ntoa() but that is broken
	 * in HP-UX + GCC + 64bitint (returns "0.0.0.0"),
	 * so let's use this sprintf() workaround everywhere.
	 * This is also more threadsafe than using inet_ntoa(). */
	ST(0) = sv_2mortal(Perl_newSVpvf(aTHX_ "%d.%d.%d.%d", /* IPv6? */
					 ((addr.s_addr >> 24) & 0xFF),
					 ((addr.s_addr >> 16) & 0xFF),
					 ((addr.s_addr >>  8) & 0xFF),
					 ( addr.s_addr        & 0xFF)));
	}

void
sockaddr_family(sockaddr)
	SV *	sockaddr
	PREINIT:
	STRLEN sockaddr_len;
	char *sockaddr_pv = SvPVbyte(sockaddr, sockaddr_len);
	CODE:
	if (sockaddr_len < offsetof(struct sockaddr, sa_data))
		croak("Bad arg length for %s, length is %"UVuf", should be at least %"UVuf,
		      "Socket::sockaddr_family", (UV)sockaddr_len,
		      (UV)offsetof(struct sockaddr, sa_data));
	ST(0) = sv_2mortal(newSViv(((struct sockaddr*)sockaddr_pv)->sa_family));

void
pack_sockaddr_un(pathname)
	SV *	pathname
	CODE:
	{
#ifdef I_SYS_UN
	struct sockaddr_un sun_ad; /* fear using sun */
	STRLEN len;
	char * pathname_pv;
	int addr_len;

	Zero(&sun_ad, sizeof(sun_ad), char);
	sun_ad.sun_family = AF_UNIX;
	pathname_pv = SvPV(pathname,len);
	if (len > sizeof(sun_ad.sun_path))
	    len = sizeof(sun_ad.sun_path);
#  ifdef OS2	/* Name should start with \socket\ and contain backslashes! */
	{
		int off;
		char *s, *e;

		if (pathname_pv[0] != '/' && pathname_pv[0] != '\\')
			croak("Relative UNIX domain socket name '%s' unsupported",
			      pathname_pv);
		else if (len < 8
			 || pathname_pv[7] != '/' && pathname_pv[7] != '\\'
			 || !strnicmp(pathname_pv + 1, "socket", 6))
			off = 7;
		else
			off = 0;	/* Preserve names starting with \socket\ */
		Copy("\\socket", sun_ad.sun_path, off, char);
		Copy(pathname_pv, sun_ad.sun_path + off, len, char);

		s = sun_ad.sun_path + off - 1;
		e = s + len + 1;
		while (++s < e)
			if (*s = '/')
				*s = '\\';
	}
#  else	/* !( defined OS2 ) */
	Copy(pathname_pv, sun_ad.sun_path, len, char);
#  endif
	if (0) not_here("dummy");
	if (len > 1 && sun_ad.sun_path[0] == '\0') {
		/* Linux-style abstract-namespace socket.
		 * The name is not a file name, but an array of arbitrary
		 * character, starting with \0 and possibly including \0s,
		 * therefore the length of the structure must denote the
		 * end of that character array */
		addr_len = (char *)&(sun_ad.sun_path) - (char *)&sun_ad + len;
	} else {
		addr_len = sizeof(sun_ad);
	}
#  ifdef HAS_SOCKADDR_SA_LEN
	sun_ad.sun_len = addr_len;
#  endif
	ST(0) = sv_2mortal(newSVpvn((char *)&sun_ad, addr_len));
#else
	ST(0) = (SV*)not_here("pack_sockaddr_un");
#endif
	
	}

void
unpack_sockaddr_un(sun_sv)
	SV *	sun_sv
	CODE:
	{
#ifdef I_SYS_UN
	struct sockaddr_un addr;
	STRLEN sockaddrlen;
	char * sun_ad = SvPVbyte(sun_sv,sockaddrlen);
	int addr_len;
#   ifndef __linux__
	/* On Linux sockaddrlen on sockets returned by accept, recvfrom,
	   getpeername and getsockname is not equal to sizeof(addr). */
	if (sockaddrlen != sizeof(addr))
		croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		      "Socket::unpack_sockaddr_un", (UV)sockaddrlen, (UV)sizeof(addr));
#   endif

	Copy(sun_ad, &addr, sizeof(addr), char);

	if (addr.sun_family != AF_UNIX)
		croak("Bad address family for %s, got %d, should be %d",
		      "Socket::unpack_sockaddr_un", addr.sun_family, AF_UNIX);

	if (addr.sun_path[0] == '\0') {
		/* Linux-style abstract socket address begins with a nul
		 * and can contain nuls. */
		addr_len = (char *)&addr - (char *)&(addr.sun_path) + sockaddrlen;
	} else {
		for (addr_len = 0; addr.sun_path[addr_len]
		     && addr_len < (int)sizeof(addr.sun_path); addr_len++);
	}

	ST(0) = sv_2mortal(newSVpvn(addr.sun_path, addr_len));
#else
	ST(0) = (SV*)not_here("unpack_sockaddr_un");
#endif
	}

void
pack_sockaddr_in(port, ip_address_sv)
	unsigned short	port
	SV *	ip_address_sv
	CODE:
	{
	struct sockaddr_in sin;
	struct in_addr addr;
	STRLEN addrlen;
	char * ip_address;
	if (DO_UTF8(ip_address_sv) && !sv_utf8_downgrade(ip_address_sv, 1))
		croak("Wide character in %s", "Socket::pack_sockaddr_in");
	ip_address = SvPVbyte(ip_address_sv, addrlen);
	if (addrlen == sizeof(addr) || addrlen == 4)
		addr.s_addr =
		    (ip_address[0] & 0xFF) << 24 |
		    (ip_address[1] & 0xFF) << 16 |
		    (ip_address[2] & 0xFF) <<  8 |
		    (ip_address[3] & 0xFF);
	else
		croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		      "Socket::pack_sockaddr_in",
		      (UV)addrlen, (UV)sizeof(addr));
	Zero(&sin, sizeof(sin), char);
	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);
	sin.sin_addr.s_addr = htonl(addr.s_addr);
#  ifdef HAS_SOCKADDR_SA_LEN
	sin.sin_len = sizeof(sin);
#  endif
	ST(0) = sv_2mortal(newSVpvn((char *)&sin, sizeof(sin)));
	}

void
unpack_sockaddr_in(sin_sv)
	SV *	sin_sv
	PPCODE:
	{
	STRLEN sockaddrlen;
	struct sockaddr_in addr;
	unsigned short	port;
	struct in_addr	ip_address;
	char *	sin = SvPVbyte(sin_sv,sockaddrlen);
	if (sockaddrlen != sizeof(addr)) {
	    croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		  "Socket::unpack_sockaddr_in", sockaddrlen, sizeof(addr));
	}
	Copy(sin, &addr, sizeof(addr), char);
	if (addr.sin_family != AF_INET) {
	    croak("Bad address family for %s, got %d, should be %d",
		  "Socket::unpack_sockaddr_in", addr.sin_family, AF_INET);
	}
	port = ntohs(addr.sin_port);
	ip_address = addr.sin_addr;

	EXTEND(SP, 2);
	PUSHs(sv_2mortal(newSViv((IV) port)));
	PUSHs(sv_2mortal(newSVpvn((char *)&ip_address, sizeof(ip_address))));
	}

void
pack_sockaddr_in6(port, sin6_addr, scope_id=0, flowinfo=0)
	unsigned short	port
	SV *	sin6_addr
	unsigned long	scope_id
	unsigned long	flowinfo
	CODE:
	{
#ifdef HAS_SOCKADDR_IN6
	struct sockaddr_in6 sin6;
	char * addrbytes;
	STRLEN addrlen;
	if (DO_UTF8(sin6_addr) && !sv_utf8_downgrade(sin6_addr, 1))
		croak("Wide character in %s", "Socket::pack_sockaddr_in6");
	addrbytes = SvPVbyte(sin6_addr, addrlen);
	if (addrlen != sizeof(sin6.sin6_addr))
		croak("Bad arg length %s, length is %"UVuf", should be %"UVuf,
		      "Socket::pack_sockaddr_in6", (UV)addrlen, (UV)sizeof(sin6.sin6_addr));
	Zero(&sin6, sizeof(sin6), char);
	sin6.sin6_family = AF_INET6;
	sin6.sin6_port = htons(port);
	sin6.sin6_flowinfo = htonl(flowinfo);
	Copy(addrbytes, &sin6.sin6_addr, sizeof(sin6.sin6_addr), char);
#  ifdef HAS_SIN6_SCOPE_ID
	sin6.sin6_scope_id = scope_id;
#  else
	if (scope_id != 0)
	    warn("%s cannot represent non-zero scope_id %d",
		 "Socket::pack_sockaddr_in6", scope_id);
#  endif
#  ifdef HAS_SOCKADDR_SA_LEN
	sin6.sin6_len = sizeof(sin6);
#  endif
	ST(0) = sv_2mortal(newSVpvn((char *)&sin6, sizeof(sin6)));
#else
	ST(0) = (SV*)not_here("pack_sockaddr_in6");
#endif
	}

void
unpack_sockaddr_in6(sin6_sv)
	SV *	sin6_sv
	PPCODE:
	{
#ifdef HAS_SOCKADDR_IN6
	STRLEN addrlen;
	struct sockaddr_in6 sin6;
	char * addrbytes = SvPVbyte(sin6_sv, addrlen);
	if (addrlen != sizeof(sin6))
		croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		      "Socket::unpack_sockaddr_in6", (UV)addrlen, (UV)sizeof(sin6));
	Copy(addrbytes, &sin6, sizeof(sin6), char);
	if (sin6.sin6_family != AF_INET6)
		croak("Bad address family for %s, got %d, should be %d",
		      "Socket::unpack_sockaddr_in6", sin6.sin6_family, AF_INET6);
	EXTEND(SP, 4);
	mPUSHi(ntohs(sin6.sin6_port));
	mPUSHp((char *)&sin6.sin6_addr, sizeof(sin6.sin6_addr));
#  ifdef HAS_SIN6_SCOPE_ID
	mPUSHi(sin6.sin6_scope_id);
#  else
	mPUSHi(0);
#  endif
	mPUSHi(ntohl(sin6.sin6_flowinfo));
#else
	ST(0) = (SV*)not_here("pack_sockaddr_in6");
#endif
	}

void
inet_ntop(af, ip_address_sv)
	int	af
	SV *	ip_address_sv
	CODE:
#ifdef HAS_INETNTOP
	STRLEN addrlen, struct_size;
#ifdef AF_INET6
	struct in6_addr addr;
	char str[INET6_ADDRSTRLEN];
#else
	struct in_addr addr;
	char str[INET_ADDRSTRLEN];
#endif
	char *ip_address = SvPV(ip_address_sv, addrlen);

	struct_size = sizeof(addr);

	if (af != AF_INET
#ifdef AF_INET6
	    && af != AF_INET6
#endif
	   ) {
		croak("Bad address family for %s, got %d, should be"
#ifdef AF_INET6
		      " either AF_INET or AF_INET6",
#else
		      " AF_INET",
#endif
		      "Socket::inet_ntop", af);
	}

	Copy(ip_address, &addr, sizeof addr, char);
	inet_ntop(af, &addr, str, sizeof str);

	ST(0) = sv_2mortal(newSVpvn(str, strlen(str)));
#else
	ST(0) = (SV*)not_here("inet_ntop");
#endif

void
inet_pton(af, host)
	int	      af
	const char *  host
	CODE:
#ifdef HAS_INETPTON
	int ok;
#ifdef AF_INET6
	struct in6_addr ip_address;
#else
	struct in_addr ip_address;
#endif

	if (af != AF_INET
#ifdef AF_INET6
	    && af != AF_INET6
#endif
	   ) {
		croak("Bad address family for %s, got %d, should be"
#ifdef AF_INET6
		      " either AF_INET or AF_INET6",
#else
		      " AF_INET",
#endif
		      "Socket::inet_pton", af);
	}
	ok = (*host != '\0') && inet_pton(af, host, &ip_address);

	ST(0) = sv_newmortal();
	if (ok) {
		sv_setpvn( ST(0), (char *)&ip_address, sizeof(ip_address) );
	}
#else
	ST(0) = (SV*)not_here("inet_pton");
#endif

void
pack_ipv6_mreq(addr, interface)
	SV *	addr
	unsigned int	interface
	CODE:
	{
#ifdef HAS_IPV6_MREQ
	struct ipv6_mreq mreq;
	char * addrbytes;
	STRLEN addrlen;
	if (DO_UTF8(addr) && !sv_utf8_downgrade(addr, 1))
		croak("Wide character in %s", "Socket::pack_ipv6_mreq");
	addrbytes = SvPVbyte(addr, addrlen);
	if (addrlen != sizeof(mreq.ipv6mr_multiaddr))
		croak("Bad arg length %s, length is %"UVuf", should be %"UVuf,
		      "Socket::pack_ipv6_mreq", (UV)addrlen, (UV)sizeof(mreq.ipv6mr_multiaddr));
	Zero(&mreq, sizeof(mreq), char);
	Copy(addrbytes, &mreq.ipv6mr_multiaddr, sizeof(mreq.ipv6mr_multiaddr), char);
	mreq.ipv6mr_interface = interface;
	ST(0) = sv_2mortal(newSVpvn((char *)&mreq, sizeof(mreq)));
#else
	ST(0) = (SV*)not_here("pack_ipv6_mreq");
#endif
	}

void
unpack_ipv6_mreq(mreq_sv)
	SV * mreq_sv
	PPCODE:
	{
#ifdef HAS_IPV6_MREQ
	struct ipv6_mreq mreq;
	STRLEN mreqlen;
	char * mreqbytes = SvPVbyte(mreq_sv, mreqlen);
	if (mreqlen != sizeof(mreq))
		croak("Bad arg length for %s, length is %"UVuf", should be %"UVuf,
		      "Socket::unpack_ipv6_mreq", (UV)mreqlen, (UV)sizeof(mreq));
	Copy(mreqbytes, &mreq, sizeof(mreq), char);
	EXTEND(SP, 2);
	mPUSHp((char *)&mreq.ipv6mr_multiaddr, sizeof(mreq.ipv6mr_multiaddr));
	mPUSHi(mreq.ipv6mr_interface);
#else
	not_here("unpack_ipv6_mreq");
#endif
	}
