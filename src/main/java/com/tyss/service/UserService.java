package com.tyss.service;

import java.security.Principal;
import java.util.Collections;
import java.util.Optional;

import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.tyss.entity.User;
import com.tyss.repo.UserRepo;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {

	private final UserRepo userRepo;

	@Override
	public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
		
		User user = userRepo.findByEmail(email).orElseThrow(() -> new UsernameNotFoundException(email));
		
		return org.springframework.security.core.userdetails.
				User
				.withUsername(user.getEmail())
				.password(user.getPassword())
				.authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")))
				.accountExpired(false)
				.accountLocked(false)
				.credentialsExpired(false)
				.disabled(false)
				.build();
	}
	
	public Integer getUid(Principal principal) {
		Optional<User> opt = userRepo.findByEmail(principal.getName());
		Integer uid = opt.get().getUid();
		return uid;
	}

}
