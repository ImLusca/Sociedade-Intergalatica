import Cookies from 'js-cookie';

export const getUserClassFromCookies = () => {
    return Cookies.get('userClass');
};

export const setUserClassInCookies = (userClass) => {
    Cookies.set('userClass', userClass, { expires: 2 });
};

export const getUserNameFromCookies = () => {
    return Cookies.get('userName');
};

export const setUserNameInCookies = (userClass) => {
    Cookies.set('userName', userClass, { expires: 2 });
};
