package com.tyss.controller;

import java.security.Principal;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.tyss.entity.User;
import com.tyss.repo.CourseRepo;
import com.tyss.repo.StudentRepo;
import com.tyss.repo.UserRepo;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class DashboardController {

	private final CourseRepo courseRepo;

	private final UserRepo userRepo;

	private final StudentRepo studentRepo;

	@GetMapping("/dashboard")
	public String dashboardPage(Model model, Principal principal, @RequestParam(required = false) String msg) {

		String email = principal.getName();

		Optional<User> opt = userRepo.findByEmail(email);

		if (opt.isEmpty()) {
			return "redirect:/login?msg=Please Login Again!!";
		}

		Integer totalCourses = courseRepo.countByUserUid(opt.get().getUid());
		
		Integer totalStudents = studentRepo.countByUserUid(opt.get().getUid());

		List<String> courses = courseRepo.getRecentCourses(opt.get().getUid());
		
		List<String> students = studentRepo.getRecentStudents(opt.get().getUid());

		model.addAttribute("recentCourses", courses);
		
		model.addAttribute("recentStudents", students);

		model.addAttribute("totalCourses", totalCourses);
		
		model.addAttribute("totalStudents", totalStudents);

		model.addAttribute("msg", msg);
		
		return "dashboard";
	}

}
