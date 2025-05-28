// Function to detect mobile devices
function isMobileDevice() {
  return (window.innerWidth <= 768 || window.innerHeight <= 500) ||
    /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
}

document.getElementById('demoButton').addEventListener('click', function () {
  const hiddenFields = {
    "Email": document.getElementById("emailInput").value,
    "DSCORGPKG__Job_Function__c": document.getElementById("roleInput").value,
    "Industry": document.getElementById("industryInput").value
  };

  MktoForms2.getForm(3357).addHiddenFields(hiddenFields).submit();
});

document.addEventListener("DOMContentLoaded", () => {
  // Mobile detection and message display
  const mobileOverlay = document.getElementById("mobileOverlay");

  if (isMobileDevice()) {
    mobileOverlay.classList.remove("hidden");
    document.body.classList.add("overflow-hidden"); // Prevent scrolling behind overlay
  } else {
    mobileOverlay.classList.add("hidden");
    document.body.classList.remove("overflow-hidden");
  }

  // Also handle resize events in case user rotates device
  window.addEventListener("resize", () => {
    if (isMobileDevice()) {
      mobileOverlay.classList.remove("hidden");
      document.body.classList.add("overflow-hidden");
    } else {
      mobileOverlay.classList.add("hidden");
      document.body.classList.remove("overflow-hidden");
    }
  });

  const state = {
    email: "",
    role: "",
    industry: "",
    hover: false,
    roles: [
      "DevOps",
      "Cloud Architect",
      "Network Engineer",
      "Security Engineer",
      "Other",
    ],
    industries: [
      "Finance",
      "Healthcare",
      "Technology",
      "Education",
      "Manufacturing",
      "Other",
    ],
    restricted_domains: [
      "gmail.com",
      "yahoo.com",
      "hotmail.com",
      "outlook.com",
      "icloud.com",
      "aol.com",
      "mail.com",
      "gmx.com",
      "protonmail.com",
      "zoho.com",
      "yandex.com",
      "paloaltonetworks.com",
      "cisco.com",
      "fortinet.com",
      "vmware.com",
      "f5.com",
      "zscaler.com",
      "netskope.com",
      "akamai.com",
      "cloudflare.com",
      "broadcom.com",
    ],
    showRoles: false,
    showIndustries: false,
  };

  // Email validation function
  function validateEmail(email) {
    // Check if it's a valid email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) return false;

    // Check if domain is restricted
    const domain = email.split('@')[1];
    return !state.restricted_domains.includes(domain);
  }

  // Setup email validation
  const emailInput = document.getElementById("emailInput");
  const emailError = document.createElement("div");
  emailError.className = "absolute text-red-500 text-xs mt-1 hidden";
  emailError.textContent = "Please type a valid Business email";
  emailInput.parentNode.appendChild(emailError);

  emailInput.addEventListener("blur", () => {
    state.email = emailInput.value.trim();
    if (state.email && !validateEmail(state.email)) {
      emailError.classList.remove("hidden");
      emailInput.classList.add("border-red-500");
    } else {
      emailError.classList.add("hidden");
      emailInput.classList.remove("border-red-500");
    }
  });

  emailInput.addEventListener("focus", () => {
    emailError.classList.add("hidden");
  });

  // Elements
  const roleInput = document.getElementById("roleInput");
  const industryInput = document.getElementById("industryInput");
  const roleDropdown = document.getElementById("roleDropdown");
  const industryDropdown = document.getElementById("industryDropdown");
  const demoButton = document.getElementById("demoButton");

  // Populate role dropdown
  state.roles.forEach((role) => {
    const div = document.createElement("div");
    div.className =
      "role-option px-2 py-1 text-sm cursor-pointer hover:bg-gray-100";
    div.textContent = role;
    roleDropdown.appendChild(div);
  });

  // Populate industry dropdown
  state.industries.forEach((industry) => {
    const div = document.createElement("div");
    div.className =
      "industry-option px-2 py-1 text-sm cursor-pointer hover:bg-gray-100";
    div.textContent = industry;
    industryDropdown.appendChild(div);
  });

  // Role dropdown handlers
  roleInput.addEventListener("click", () => {
    state.showRoles = !state.showRoles;
    roleDropdown.classList.toggle("hidden");
    industryDropdown.classList.add("hidden");
    state.showIndustries = false;
  });

  document.querySelectorAll(".role-option").forEach((option) => {
    option.addEventListener("click", (e) => {
      state.role = e.target.textContent;
      roleInput.value = state.role;
      roleDropdown.classList.add("hidden");
      state.showRoles = false;
    });
  });

  // Industry dropdown handlers
  industryInput.addEventListener("click", () => {
    state.showIndustries = !state.showIndustries;
    industryDropdown.classList.toggle("hidden");
    roleDropdown.classList.add("hidden");
    state.showRoles = false;
  });

  document.querySelectorAll(".industry-option").forEach((option) => {
    option.addEventListener("click", (e) => {
      state.industry = e.target.textContent;
      industryInput.value = state.industry;
      industryDropdown.classList.add("hidden");
      state.showIndustries = false;
    });
  });

  // Button hover effects
  demoButton.addEventListener("mouseenter", () => {
    state.hover = true;
    demoButton.style.transform = "translateY(-2px)";
    demoButton.style.boxShadow = "0 4px 40px rgba(250,107,30,0.4)";
  });

  demoButton.addEventListener("mouseleave", () => {
    state.hover = false;
    demoButton.style.transform = "none";
    demoButton.style.boxShadow = "0 2px 40px rgba(250,107,30,0.2)";
  });

  // Close dropdowns when clicking outside
  document.addEventListener("click", (e) => {
    if (!roleInput.contains(e.target) && !roleDropdown.contains(e.target)) {
      roleDropdown.classList.add("hidden");
      state.showRoles = false;
    }
    if (
      !industryInput.contains(e.target) &&
      !industryDropdown.contains(e.target)
    ) {
      industryDropdown.classList.add("hidden");
      state.showIndustries = false;
    }
  });

  // Form submission
  demoButton.addEventListener("click", (e) => {
    e.preventDefault();
    if (!state.email || !state.role || !state.industry) {
      alert("Please fill out all fields");
      return;
    }
    if (!validateEmail(state.email)) {
      alert("Please type a valid Business email");
      return;
    }
    console.log(state);

    function setCookie(name, value, days) {
      const d = new Date();
      d.setTime(d.getTime() + days * 24 * 60 * 60 * 1000);
      const expires = "expires=" + d.toUTCString();
      document.cookie =
        name + "=" + encodeURIComponent(value) + ";" + expires + ";path=/";
    }

    // Set cookies (you might choose an appropriate max-age)
    setCookie("user_businessEmail", btoa(
      state.email
    ), 365);
    setCookie("user_role", btoa(state.role), 365);
    setCookie("user_industry", btoa(
      state.industry), 365);

    // Optionally, you could set a flag indicating captive auth is complete
    setCookie("captive_auth", "1", 365);

    window.location.href = "/";

  }
  );

});
